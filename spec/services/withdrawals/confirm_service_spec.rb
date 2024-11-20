require 'rails_helper'

RSpec.describe Withdrawals::ConfirmService, type: :service do
  let(:user) { create(:user) }
  let!(:wallet) { create(:wallet, user: user, balance: 400.0) }
  let!(:withdrawal) do
    create(:withdrawal, user: user, amount: 100.0, order_no: 'ORDER123', platform: 'visa', status: 'pending')
  end
  let!(:event) { create(:event, eventable: withdrawal, user: user, event_type: 'withdrawal') }

  describe '#call' do
    context 'when the status is success' do
      let(:params) { { order_no: 'ORDER123', platform: 'visa', status: 'success' } }

      it 'updates the withdrawal status to success and creates a success event' do
        service = described_class.new(params)

        expect { service.call }
          .to change { withdrawal.reload.status }.from('pending').to('success')
                                                 .and change { Event.count }.by(1)

        event = Event.order(created_at: :desc).first
        expect(event.eventable).to eq(withdrawal)
        expect(event.event_type).to eq('withdrawal')
        expect(event.related_event_id).to eq(withdrawal.events.order(created_at: :desc).first(2).last.id)
      end
    end

    context 'when the status is failed with a reason' do
      let(:params) do
        { order_no: 'ORDER123', platform: 'visa', status: 'failed', reason: 'network error' }
      end

      it 'updates the withdrawal status to failed, restores wallet balance, and creates a failed event' do
        service = described_class.new(params)

        expect { service.call }
          .to change { withdrawal.reload.status }.from('pending').to('failed')
                                                 .and change { wallet.reload.balance }.from(400.0).to(500.0)
                                                                                      .and change { Event.count }.by(1)

        expect(withdrawal.reload.metadata['failed_reason']).to eq('network error')

        event = Event.order(created_at: :desc).first
        expect(event.eventable).to eq(withdrawal)
        expect(event.event_type).to eq('withdrawal')
        expect(event.related_event_id).to eq(withdrawal.events.order(created_at: :desc).first(2).last.id)
      end
    end

    context 'when the withdrawal is not found' do
      let(:params) { { order_no: 'INVALID', platform: 'visa', status: 'success' } }

      it 'does nothing' do
        service = described_class.new(params)

        expect { service.call }.not_to change { Withdrawal.count }
        expect { service.call }.not_to change { Event.count }
      end
    end

    context 'when the withdrawal status is not pending' do
      before do
        withdrawal.update!(status: 'failed')
      end

      let(:params) { { order_no: 'ORDER123', platform: 'visa', status: 'success' } }

      it 'does nothing' do
        service = described_class.new(params)

        expect { service.call }.not_to change { withdrawal.reload.status }
        expect(wallet.reload.balance).to eq(400.0)
        expect { service.call }.not_to change { Event.count }
      end
    end
  end
end
