# spec/models/withdrawal_spec.rb

require 'rails_helper'

RSpec.describe Withdrawal, type: :model do
  describe 'associations' do
    it { should have_many(:events) }
    it { should belong_to(:user) }
  end

  describe 'enumerations' do
    it 'defines valid statuses' do
      valid_statuses = %w[success failed pending]
      expect(Withdrawal.status.values).to match_array(valid_statuses)
    end

    it 'has a default status of pending' do
      withdrawal = build(:withdrawal)
      expect(withdrawal.status).to eq('pending')
    end

    it 'defines valid platforms' do
      valid_platforms = %w[visa mastercard cold_wallet hot_wallet]
      expect(Withdrawal.platform.values).to match_array(valid_platforms)
    end
  end

  describe '#as_api_json' do
    let(:withdrawal) do
      create(:withdrawal,
             amount: 150.75,
             platform: 'visa',
             order_no: 'ORD12345',
             status: 'success')
    end

    it 'returns the correct API representation' do
      json = withdrawal.as_api_json
      expect(json).to eq(
                        {
                          id: withdrawal.id,
                          amount: 150.75,
                          platform: 'visa',
                          order_no: 'ORD12345',
                          status: 'success',
                          created_at: withdrawal.created_at.strftime('%F %T'),
                          updated_at: withdrawal.updated_at.strftime('%F %T')
                        }
                      )
    end
  end
end
