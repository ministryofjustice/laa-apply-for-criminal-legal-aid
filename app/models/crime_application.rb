class CrimeApplication < ApplicationRecord
  has_one :applicant, dependent: :destroy
  has_one :partner, dependent: :destroy

  # Must be included after people relationships
  include HasContactDetailsThroughPeople
end
