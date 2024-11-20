require 'rails_helper'

RSpec.describe Transfers::CreateService, type: :service do
  let(:user) { create(:user) }
  let(:to_user) { create(:user) }
  let!(:user_wallet) { create(:wallet, user: user, balance: 500.0) }
  let!(:to_user_wallet) { create(:wallet, user: to_user, balance: 300.0) }

  describe '#call' do
    context 'when transferring to oneself' do
      it 'raises a ValidationError' do
        params = { to_user_id: user.id, amount: 100.0 }
        service = described_class.new(user, params)

        expect { service.call }.to raise_error(::ValidationError, 'Can not transfer to yourself.')
      end
    end

    context 'when transferring a non-positive amount' do
      it 'raises a ValidationError for zero amount' do
        params = { to_user_id: to_user.id, amount: 0.0 }
        service = described_class.new(user, params)

        expect { service.call }.to raise_error(::ValidationError, 'please input correct amount.')
      end

      it 'raises a ValidationError for negative amount' do
        params = { to_user_id: to_user.id, amount: -50.0 }
        service = described_class.new(user, params)

        expect { service.call }.to raise_error(::ValidationError, 'please input correct amount.')
      end
    end

    context 'when the user has insufficient balance' do
      it 'raises a TransferError' do
        params = { to_user_id: to_user.id, amount: 600.0 }
        service = described_class.new(user, params)

        expect { service.call }.to raise_error(::TransferError, 'Insufficient balance.')
      end
    end

    context 'when the transfer is successful' do
      it 'updates the wallet balances and creates the transfer and events' do
        params = { to_user_id: to_user.id, amount: 100.0 }
        service = described_class.new(user, params)

        expect { service.call }.to change { user_wallet.reload.balance }.from(500.0).to(400.0)
                                                                        .and change { to_user_wallet.reload.balance }.from(300.0).to(400.0)
                                                                                                                     .and change { Transfer.count }.by(1)
                                                                                                                                                   .and change { Event.count }.by(2)

        transfer = Transfer.last
        expect(transfer.amount).to eq(100.0)
        expect(transfer.from_user_id).to eq(user.id)
        expect(transfer.to_user_id).to eq(to_user.id)

        transfer_out_event = Event.find_by(eventable: transfer, event_type: 'transfer_out')
        transfer_in_event = Event.find_by(eventable: transfer, event_type: 'transfer_in')

        expect(transfer_out_event.related_event_id).to eq(transfer_in_event.id)
        expect(transfer_in_event.related_event_id).to eq(transfer_out_event.id)
      end
    end
  end
end
