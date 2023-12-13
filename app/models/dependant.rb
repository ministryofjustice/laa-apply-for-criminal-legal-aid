class Dependant < ApplicationRecord
  MAX_AGE = 18

  belongs_to :crime_application

  # Using UUIDs as the record IDs. We can't trust sequential ordering by ID
  default_scope { order(created_at: :asc) }

  scope :with_ages, -> { where.not(age: nil) }
end
