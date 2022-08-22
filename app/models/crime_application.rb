class CrimeApplication < ApplicationRecord
  has_one :applicant, dependent: :destroy
  has_one :partner, dependent: :destroy

  has_many :people, dependent: :destroy
  has_many :addresses, through: :people

  enum status: {
    newly_initialised: ApplicationStatus::NEWLY_INITIALISED.to_s,
    in_progress: ApplicationStatus::IN_PROGRESS.to_s,
    completed:   ApplicationStatus::COMPLETED.to_s
  }, _default: ApplicationStatus::NEWLY_INITIALISED.to_s
end
