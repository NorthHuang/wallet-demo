require 'rails_helper'

RSpec.describe User, type: :model do
  subject { create(:user, name: "Test User", email: "test@example.com", password: "password") }
  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should validate_presence_of(:password) }
    it { should validate_length_of(:password).is_at_least(6) }
  end

  describe 'associations' do
    it { should have_one(:wallet) }
    it { should have_many(:withdrawals) }
    it { should have_many(:deposits) }
    it { should have_many(:events) }
    it { should have_many(:transfer_outs).class_name('Transfer').with_foreign_key(:from_user_id) }
    it { should have_many(:transfer_ins).class_name('Transfer').with_foreign_key(:to_user_id) }
  end

  describe '#as_api_json' do
    let(:user) { create(:user, name: 'John Doe', email: 'john@example.com') }

    it 'returns the correct API representation' do
      json = user.as_api_json
      expect(json).to eq(
                        {
                          id: user.id,
                          email: 'john@example.com',
                          name: 'John Doe',
                          created_at: user.created_at.strftime('%F %T'),
                          updated_at: user.updated_at.strftime('%F %T')
                        }
                      )
    end
  end
end
