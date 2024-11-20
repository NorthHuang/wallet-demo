require 'rails_helper'

RSpec.describe Wallet, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
  end

  describe '#as_api_json' do
    let(:wallet) { create(:wallet) }

    it 'returns the correct API representation' do
      json = wallet.as_api_json
      expect(json).to eq(
                        {
                          id: wallet.id,
                          balance: 100.12,
                          created_at: wallet.created_at.strftime('%F %T'),
                          updated_at: wallet.updated_at.strftime('%F %T')
                        }
                      )
    end
  end
end
