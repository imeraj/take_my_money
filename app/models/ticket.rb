class Ticket < ApplicationRecord

  belongs_to :user, optional: true
  belongs_to :performance
  has_one :event, through: :performance
end
