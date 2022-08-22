class CrimeApplication < ApplicationRecord
  has_one :applicant, dependent: :destroy
  has_one :partner, dependent: :destroy

  has_many :people, dependent: :destroy
  has_many :addresses, through: :people

  enum status: {
    newly_initialised: ApplicationStatus::NEWLY_INITIALISED,
    in_progress: ApplicationStatus::IN_PROGRESS,
    completed:   ApplicationStatus::COMPLETED
  }, _default: :newly_initialised
end
