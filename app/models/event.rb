class Event < ApplicationRecord
  belongs_to :eventable, polymorphic: true
  belongs_to :user

  extend Enumerize

  enumerize :event_type, in: [:transfer_in, :transfer_out, :withdrawal, :deposit]
end
