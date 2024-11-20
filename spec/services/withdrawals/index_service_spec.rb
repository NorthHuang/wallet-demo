# spec/services/withdrawals/index_service_spec.rb

require 'rails_helper'

RSpec.describe Withdrawals::IndexService, type: :service do
  let(:user) { create(:user) }
  let!(:withdrawal1) { create(:withdrawal, user: user, amount: 100.0, order_no: 'WITH123') }
  let!(:withdrawal2) { create(:withdrawal, user: user, amount: 200.0, order_no: 'WITH124') }
  let!(:other_user_withdrawal) { create(:withdrawal, amount: 300.0, order_no: 'WITH125') } # Not associated with the user

  describe '#call' do
    context 'when there are withdrawals for the user' do
      it 'returns the withdrawals as paginated JSON' do
        service = described_class.new(user, { page: 1, per: 10 })
        result = service.call

        expect(result.size).to eq(2)
        expect(result.map { |w| w[:order_no] }).to contain_exactly('WITH123', 'WITH124')
        expect(result.map { |w| w[:amount] }).to contain_exactly(100.0, 200.0)
      end
    end

    context 'when there are no withdrawals for the user' do
      let(:new_user) { create(:user) }

      it 'returns an empty array' do
        service = described_class.new(new_user, { page: 1, per: 10 })
        result = service.call

        expect(result).to eq([])
      end
    end

    context 'with pagination' do
      before do
        create_list(:withdrawal, 15, user: user) # Create additional withdrawals
      end

      it 'returns only withdrawals for the specified page and per' do
        service = described_class.new(user, { page: 1, per: 10 })
        result = service.call

        expect(result.size).to eq(10) # First page should contain 10 items
      end

      it 'returns the remaining withdrawals for the next page' do
        service = described_class.new(user, { page: 2, per: 10 })
        result = service.call

        expect(result.size).to eq(7) # Second page should contain the remaining 7 items
      end
    end
  end
end
