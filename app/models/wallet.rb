class Wallet < ApplicationRecord
  belongs_to :user

  def as_api_json
    {
      id: id,
      balance: balance.to_f,
      created_at: created_at.strftime('%F %T'),
      updated_at: updated_at.strftime('%F %T')
    }
  end
end
