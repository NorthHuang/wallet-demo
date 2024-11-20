class Transfer < ApplicationRecord
  has_many :events, as: :eventable
  belongs_to :from_user, class_name: 'User', foreign_key: 'from_user_id'
  belongs_to :to_user, class_name: 'User', foreign_key: 'to_user_id'

  def as_api_json
    {
      id: id,
      from_user_id: from_user_id,
      to_user_id: to_user_id,
      created_at: created_at.strftime('%F %T'),
      updated_at: updated_at.strftime('%F %T')
    }
  end

  def as_in_api_json
    as_api_json.merge(
      from_user_name: from_user.name,
      amount: amount.to_f
    )
  end

  def as_out_api_json
    as_api_json.merge(
      to_user_name: to_user.name,
      amount: -amount.to_f
    )
  end

  def as_all_api_json(user_id)
    as_api_json.merge(
      direction: user_id == from_user_id ? 'out' : 'in',
      from_user_name: from_user.name,
      to_user_name: to_user.name,
      amount: user_id == from_user_id ? -amount.to_f : amount.to_f
    )
  end
end
