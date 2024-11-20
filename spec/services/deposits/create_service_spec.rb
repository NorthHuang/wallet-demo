require 'rails_helper'

RSpec.describe Deposits::CreateService, type: :service do
  let(:user) { create(:user, email: 'test@example.com') }
  let!(:wallet) { create(:wallet, user: user, balance: 500.0) }

  describe '#call' do
    context 'when deposit is successful' do
      let(:params) do
        {
          order_no: 'DEP12345',
          platform: 'visa',
          amount: 100.0,
          email: 'test@example.com'
        }
      end

      it 'increments the wallet balance and creates a deposit and event' do
        service = described_class.new(params)

        expect { service.call }.to change { wallet.reload.balance }.from(500.0).to(600.0)
                                                                   .and change { Deposit.count }.by(1)
                                                                                                .and change { Event.count }.by(1)

        deposit = Deposit.last
        expect(deposit.amount).to eq(100.0)
        expect(deposit.platform).to eq('visa')
        expect(deposit.order_no).to eq('DEP12345')
        expect(deposit.user_id).to eq(user.id)

        event = Event.last
        expect(event.eventable).to eq(deposit)
        expect(event.event_type).to eq('deposit')
        expect(event.user_id).to eq(user.id)
      end
    end

    context 'when the user is not found' do
      let(:params) do
        {
          order_no: 'DEP12345',
          platform: 'visa',
          amount: 100.0,
          email: 'nonexistent@example.com'
        }
      end

      it 'raises an error' do
        service = described_class.new(params)

        expect { service.call }.to raise_error(NoMethodError, /undefined method `id' for nil:NilClass/)
      end
    end
  end
end
