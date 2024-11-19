class Deposit < ApplicationRecord
  has_one :event, as: :eventable
  extend Enumerize
  enumerize :platform, in: [:visa, :mastercard, :cold_wallet, :hot_wallet]

  def as_api_json
    {
      id: id,
      amount: amount.to_f,
      platform: platform,
      order_no: order_no,
      created_at: created_at.strftime('%F %T'),
      updated_at: updated_at.strftime('%F %T')
    }
  end
end
