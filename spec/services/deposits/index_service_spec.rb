# spec/services/deposits/index_service_spec.rb

require 'rails_helper'

RSpec.describe Deposits::IndexService, type: :service do
  let(:user) { create(:user) }
  let!(:deposit1) { create(:deposit, user: user, amount: 100.0, order_no: 'DEP123') }
  let!(:deposit2) { create(:deposit, user: user, amount: 200.0, order_no: 'DEP124') }
  let!(:other_user_deposit) { create(:deposit, amount: 300.0, order_no: 'DEP125') } # Not associated with the user

  describe '#call' do
    context 'when there are deposits for the user' do
      it 'returns the deposits as paginated JSON' do
        service = described_class.new(user, { page: 1, per: 10 })
        result = service.call

        expect(result.size).to eq(2)
        expect(result.map { |d| d[:order_no] }).to contain_exactly('DEP123', 'DEP124')
        expect(result.map { |d| d[:amount] }).to contain_exactly(100.0, 200.0)
      end
    end

    context 'when there are no deposits for the user' do
      let(:new_user) { create(:user) }

      it 'returns an empty array' do
        service = described_class.new(new_user, { page: 1, per: 10 })
        result = service.call

        expect(result).to eq([])
      end
    end

    context 'with pagination' do
      before do
        create_list(:deposit, 15, user: user) # Create additional deposits
      end

      it 'returns only deposits for the specified page and per' do
        service = described_class.new(user, { page: 1, per: 10 })
        result = service.call

        expect(result.size).to eq(10) # First page should contain 10 items
      end

      it 'returns the remaining deposits for the next page' do
        service = described_class.new(user, { page: 2, per: 10 })
        result = service.call

        expect(result.size).to eq(7) # Second page should contain the remaining 7 items
      end
    end
  end
end
