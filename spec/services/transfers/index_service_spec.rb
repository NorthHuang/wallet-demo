# spec/services/transfers/index_service_spec.rb

require 'rails_helper'

RSpec.describe Transfers::IndexService, type: :service do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let!(:transfer_in) { create(:transfer, from_user: other_user, to_user: user, amount: 50.0) }
  let!(:transfer_out) { create(:transfer, from_user: user, to_user: other_user, amount: 100.0) }

  describe '#call' do
    context 'when type is "all"' do
      it 'returns all transfers for the user' do
        service = described_class.new(user, { type: 'all', page: 1, per: 10 })
        result = service.call

        expect(result.size).to eq(2)
        expect(result.map { |t| t[:id] }).to contain_exactly(transfer_in.id, transfer_out.id)
        expect(result.map { |t| t[:direction] }).to contain_exactly('in', 'out')
      end
    end

    context 'when type is "in"' do
      it 'returns only incoming transfers' do
        service = described_class.new(user, { type: 'in', page: 1, per: 10 })
        result = service.call

        expect(result.size).to eq(1)
        expect(result.first[:id]).to eq(transfer_in.id)
        expect(result.first[:amount]).to eq(50.0)
      end
    end

    context 'when type is "out"' do
      it 'returns only outgoing transfers' do
        service = described_class.new(user, { type: 'out', page: 1, per: 10 })
        result = service.call

        expect(result.size).to eq(1)
        expect(result.first[:id]).to eq(transfer_out.id)
        expect(result.first[:amount]).to eq(-100.0)
      end
    end

    context 'when type is invalid' do
      it 'returns an empty array' do
        service = described_class.new(user, { type: 'invalid', page: 1, per: 10 })
        result = service.call

        expect(result).to eq([])
      end
    end

    context 'when no type is provided' do
      it 'defaults to "all"' do
        service = described_class.new(user, { page: 1, per: 10 })
        result = service.call

        expect(result.size).to eq(2)
      end
    end
  end
end
