require 'rails_helper'

RSpec.describe Event, type: :model do
  describe 'associations' do
    it { should belong_to(:eventable) }
    it { should belong_to(:user) }
  end

  describe 'enumerations' do
    it 'defines valid event types' do
      valid_types = %w[transfer_in transfer_out withdrawal deposit]
      expect(Event.event_type.values).to match_array(valid_types)
    end
  end

  describe 'polymorphic association' do
    let(:user) { create(:user) }
    context 'when associated with a transfer' do
      let(:transfer) { create(:transfer, from_user: user) }
      let(:event) { create(:event, eventable: transfer, user: user, event_type: 'transfer_out') }

      it 'associates correctly with a transfer' do
        expect(event.eventable).to eq(transfer)
        expect(event.event_type).to eq('transfer_out')
        expect(event.user).to eq(user)
      end
    end

    context 'when associated with a deposit' do
      let(:deposit) { create(:deposit, user: user) }
      let(:event) { create(:event, eventable: deposit, user: user, event_type: 'deposit') }

      it 'associates correctly with a deposit' do
        expect(event.eventable).to eq(deposit)
        expect(event.event_type).to eq('deposit')
      end
    end

    context 'when associated with a withdrawal' do
      let(:withdrawal) { create(:withdrawal, user: user) }
      let(:event) { create(:event, eventable: withdrawal, user: user, event_type: 'withdrawal') }

      it 'associates correctly with a withdrawal' do
        expect(event.eventable).to eq(withdrawal)
        expect(event.event_type).to eq('withdrawal')
      end
    end
  end
end
