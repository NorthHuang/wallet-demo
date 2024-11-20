require 'rails_helper'

RSpec.describe Transfer, type: :model do
  describe 'associations' do
    it { should have_many(:events) }
    it { should belong_to(:from_user).class_name('User').with_foreign_key('from_user_id') }
    it { should belong_to(:to_user).class_name('User').with_foreign_key('to_user_id') }
  end

  describe 'instance methods' do
    let(:from_user) { create(:user, name: 'Alice') }
    let(:to_user) { create(:user, name: 'Bob') }
    let(:transfer) { create(:transfer, from_user: from_user, to_user: to_user, amount: 100.50) }

    describe '#as_api_json' do
      it 'returns the correct API representation' do
        json = transfer.as_api_json
        expect(json).to eq(
                          {
                            id: transfer.id,
                            from_user_id: from_user.id,
                            to_user_id: to_user.id,
                            created_at: transfer.created_at.strftime('%F %T'),
                            updated_at: transfer.updated_at.strftime('%F %T')
                          }
                        )
      end
    end

    describe '#as_in_api_json' do
      it 'returns the correct API representation for incoming transfers' do
        json = transfer.as_in_api_json
        expect(json).to eq(
                          {
                            id: transfer.id,
                            from_user_id: from_user.id,
                            to_user_id: to_user.id,
                            created_at: transfer.created_at.strftime('%F %T'),
                            updated_at: transfer.updated_at.strftime('%F %T'),
                            from_user_name: 'Alice',
                            amount: 100.50
                          }
                        )
      end
    end

    describe '#as_out_api_json' do
      it 'returns the correct API representation for outgoing transfers' do
        json = transfer.as_out_api_json
        expect(json).to eq(
                          {
                            id: transfer.id,
                            from_user_id: from_user.id,
                            to_user_id: to_user.id,
                            created_at: transfer.created_at.strftime('%F %T'),
                            updated_at: transfer.updated_at.strftime('%F %T'),
                            to_user_name: 'Bob',
                            amount: -100.50
                          }
                        )
      end
    end

    describe '#as_all_api_json' do
      it 'returns the correct API representation for outgoing transfers' do
        json = transfer.as_all_api_json(from_user.id)
        expect(json).to eq(
                          {
                            id: transfer.id,
                            from_user_id: from_user.id,
                            to_user_id: to_user.id,
                            created_at: transfer.created_at.strftime('%F %T'),
                            updated_at: transfer.updated_at.strftime('%F %T'),
                            direction: 'out',
                            from_user_name: 'Alice',
                            to_user_name: 'Bob',
                            amount: -100.50
                          }
                        )
      end

      it 'returns the correct API representation for incoming transfers' do
        json = transfer.as_all_api_json(to_user.id)
        expect(json).to eq(
                          {
                            id: transfer.id,
                            from_user_id: from_user.id,
                            to_user_id: to_user.id,
                            created_at: transfer.created_at.strftime('%F %T'),
                            updated_at: transfer.updated_at.strftime('%F %T'),
                            direction: 'in',
                            from_user_name: 'Alice',
                            to_user_name: 'Bob',
                            amount: 100.50
                          }
                        )
      end
    end
  end
end
