require 'rails_helper'

RSpec.describe Deposit, type: :model do
  describe 'associations' do
    it { should have_many(:events) }
    it { should belong_to(:user) }
  end

  describe 'enumerations' do
    it 'defines valid platforms' do
      valid_platforms = %w[visa mastercard cold_wallet hot_wallet]
      expect(Deposit.platform.values).to match_array(valid_platforms)
    end
  end

  describe '#as_api_json' do
    let(:deposit) do
      create(:deposit,
             amount: 200.50,
             platform: 'mastercard',
             order_no: 'DEP12345')
    end

    it 'returns the correct API representation' do
      json = deposit.as_api_json
      expect(json).to eq(
                        {
                          id: deposit.id,
                          amount: 200.50,
                          platform: 'mastercard',
                          order_no: 'DEP12345',
                          created_at: deposit.created_at.strftime('%F %T'),
                          updated_at: deposit.updated_at.strftime('%F %T')
                        }
                      )
    end
  end
end
