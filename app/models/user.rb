class User < ApplicationRecord
  has_secure_password

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :password, presence: true, length: { minimum: 6 }

  has_one :wallet
  has_many :withdrawals
  has_many :deposits
  has_many :events
  has_many :transfer_outs, class_name: 'Transfer', foreign_key: :from_user_id
  has_many :transfer_ins, class_name: 'Transfer', foreign_key: :to_user_id

  def as_api_json
    {
      id: id,
      email: email,
      name: name,
      created_at: created_at.strftime('%F %T'),
      updated_at: updated_at.strftime('%F %T')
    }
  end
end
