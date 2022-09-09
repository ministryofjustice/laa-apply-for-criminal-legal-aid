class Charge < ApplicationRecord
  belongs_to :case
  belongs_to :offence, optional: true

  has_many :offence_dates, dependent: :destroy
  accepts_nested_attributes_for :offence_dates, allow_destroy: true

  # Using UUIDs as the record IDs. We can't trust sequential ordering by ID
  default_scope { order(created_at: :asc) }
end
