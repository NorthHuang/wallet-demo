require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe ConfirmWithdrawalWorker, type: :worker do
  before(:each) do
    Sidekiq::Worker.clear_all
    Sidekiq::Testing.fake!
  end

  let(:user) { create(:user) }
  let!(:wallet) { create(:wallet, user: user, balance: 500.0) }
  let!(:withdrawal) { create(:withdrawal, user: user, amount: 100.0, status: 'pending') }
  let!(:event) { create(:event, eventable: withdrawal, user: user, event_type: 'withdrawal') }

  describe '#perform' do
    context 'when check_withdrawal_status returns success' do
      before do
        allow_any_instance_of(ConfirmWithdrawalWorker).to receive(:check_withdrawal_status)
                                                            .and_return({ success: true, data: { status: 'success' } })
      end

      it 'updates the withdrawal status to success and creates a success event' do
        expect {
          described_class.new.perform(withdrawal.id)
        }.to change { withdrawal.reload.status }.from('pending').to('success')
                                                .and change { Event.count }.by(1)

        event = Event.last
        expect(event.eventable).to eq(withdrawal)
        expect(event.event_type).to eq('withdrawal')
      end
    end

    context 'when check_withdrawal_status returns pending' do
      before do
        allow_any_instance_of(ConfirmWithdrawalWorker).to receive(:check_withdrawal_status)
                                                            .and_return({ success: true, data: { status: 'pending' } })
      end

      it 'reschedules the worker' do
        expect {
          described_class.new.perform(withdrawal.id)
        }.not_to change { withdrawal.reload.status }

        # Check if the worker is enqueued again
        expect(ConfirmWithdrawalWorker.jobs.size).to eq(1)
        job = ConfirmWithdrawalWorker.jobs.last
        expect(job['args']).to eq([withdrawal.id])
      end
    end

    context 'when check_withdrawal_status returns failed' do
      before do
        allow_any_instance_of(ConfirmWithdrawalWorker).to receive(:check_withdrawal_status)
                                                            .and_return({ success: true, data: { status: 'failed', reason: 'network error' } })
      end

      it 'updates the withdrawal status to failed, restores wallet balance, and creates a failed event' do
        expect {
          described_class.new.perform(withdrawal.id)
        }.to change { withdrawal.reload.status }.from('pending').to('failed')
                                                .and change { wallet.reload.balance }.from(500.0).to(600.0)
                                                                                     .and change { Event.count }.by(1)

        expect(withdrawal.reload.metadata['failed_reason']).to eq('network error')
        event = Event.last
        expect(event.eventable).to eq(withdrawal)
        expect(event.event_type).to eq('withdrawal')
      end
    end

    context 'when check_withdrawal_status returns success: false' do
      before do
        allow_any_instance_of(ConfirmWithdrawalWorker).to receive(:check_withdrawal_status)
                                                            .and_return({ success: false })
      end

      it 'reschedules the worker' do
        expect {
          described_class.new.perform(withdrawal.id)
        }.not_to change { withdrawal.reload.status }

        # Check if the worker is enqueued again
        expect(ConfirmWithdrawalWorker.jobs.size).to eq(1)
        job = ConfirmWithdrawalWorker.jobs.last
        expect(job['args']).to eq([withdrawal.id])
      end
    end

    context 'when withdrawal ID is blank' do
      it 'does nothing' do
        expect {
          described_class.new.perform(nil)
        }.not_to change { Withdrawal.count }
      end
    end

    context 'when withdrawal is not pending' do
      let!(:completed_withdrawal) { create(:withdrawal, user: user, amount: 100.0, status: 'success') }

      it 'does nothing' do
        expect {
          described_class.new.perform(completed_withdrawal.id)
        }.not_to change { completed_withdrawal.reload.status }
      end
    end
  end
end
