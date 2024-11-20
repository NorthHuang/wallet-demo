# spec/services/withdrawals/create_service_spec.rb

require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe Withdrawals::CreateService, type: :service do
  let(:user) { create(:user) }
  let!(:wallet) { create(:wallet, user: user, balance: 500.0) }

  describe '#call' do
    context 'when withdrawal is created and ConfirmWithdrawalWorker handles it' do
      let(:params) { { amount: 100.0, platform: 'visa' } }

      before do
        Sidekiq::Testing.inline!
      end

      context 'when ConfirmWithdrawalWorker returns success' do
        before do
          allow_any_instance_of(ConfirmWithdrawalWorker).to receive(:check_withdrawal_status)
                                                              .and_return({ success: true, data: { status: 'success' } })
        end

        it 'updates the withdrawal status to success and creates a success event' do
          service = described_class.new(user, params)
          expect { service.call }
            .to change { wallet.reload.balance }.from(500.0).to(400.0)
                                                .and change { Withdrawal.count }.by(1)
                                                                                .and change { Event.count }.by(2) # One for pending, one for success

          withdrawal = Withdrawal.last
          expect(withdrawal.status).to eq('success')

          event = Event.last
          expect(event.eventable).to eq(withdrawal)
          expect(event.event_type).to eq('withdrawal')
        end
      end

      context 'when ConfirmWithdrawalWorker returns pending' do
        before do
          status_sequence = [:pending, :success]
          allow_any_instance_of(ConfirmWithdrawalWorker).to receive(:check_withdrawal_status) do
            current_status = status_sequence.shift
            if current_status == :pending
              { success: true, data: { status: 'pending' } }
            else
              { success: true, data: { status: 'success' } }
            end
          end
        end

        it 'reschedules the worker and does not change the withdrawal status' do
          service = described_class.new(user, params)
          expect { service.call }
            .to change { wallet.reload.balance }.from(500.0).to(400.0).and change { Withdrawal.count }.by(1)
                                           .and change { Event.count }.by(2) # Only the initial pending event

          withdrawal = Withdrawal.last
          expect(withdrawal.status).to eq('success')

          # Check if ConfirmWithdrawalWorker is rescheduled
          expect(ConfirmWithdrawalWorker.jobs.size).to eq(0)
        end
      end

      context 'when ConfirmWithdrawalWorker returns failed' do
        before do
          allow_any_instance_of(ConfirmWithdrawalWorker).to receive(:check_withdrawal_status)
                                                              .and_return({ success: true, data: { status: 'failed', reason: 'network error' } })
        end

        it 'updates the withdrawal status to failed, restores wallet balance, and creates a failed event' do
          service = described_class.new(user, params)
          expect { service.call }
            .to  change { Withdrawal.count }.by(1).and change { Event.count }.by(2) # One for pending, one for failed

          withdrawal = Withdrawal.last
          expect(withdrawal.status).to eq('failed')
          expect(wallet.reload.balance).to eq(500.0) # Balance restored after failure

          event = Event.last
          expect(event.eventable).to eq(withdrawal)
          expect(event.event_type).to eq('withdrawal')
          expect(withdrawal.metadata['failed_reason']).to eq('network error')
        end
      end

      context 'when ConfirmWithdrawalWorker returns success: false' do
        before do
          status_sequence = [:request_failed, :success]
          allow_any_instance_of(ConfirmWithdrawalWorker).to receive(:check_withdrawal_status) do
            current_status = status_sequence.shift
            if current_status == :request_failed
              { success: false }
            else
              { success: true, data: { status: 'success' } }
            end
          end
        end

        it 'reschedules the worker and does not change the withdrawal status' do
          service = described_class.new(user, params)
          expect { service.call }
            .to  change { wallet.reload.balance }.from(500.0).to(400.0).and change { Withdrawal.count }.by(1)
                                           .and change { Event.count }.by(2) # Only the initial pending event

          withdrawal = Withdrawal.last
          expect(withdrawal.status).to eq('success')

          # Check if ConfirmWithdrawalWorker is rescheduled
          expect(ConfirmWithdrawalWorker.jobs.size).to eq(0)
        end
      end
    end

    context 'when the wallet balance is insufficient' do
      let(:params) { { amount: 600.0, platform: 'visa' } }

      it 'raises a WithdrawalError' do
        service = described_class.new(user, params)
        expect { service.call }.to raise_error(::WithdrawalError, 'Insufficient balance.')
      end
    end
  end
end
