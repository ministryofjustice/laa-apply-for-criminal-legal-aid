class Dependant < ApplicationRecord
  MAX_AGE = 18
  MAX_TOTAL_DEPENDANTS = 18 # Maximum determined by MAAT

  belongs_to :crime_application

  # Using UUIDs as the record IDs. We can't trust sequential ordering by ID
  default_scope { order(created_at: :asc) }

  scope :with_ages, -> { where.not(age: nil) }
end
