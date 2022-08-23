class CrimeApplication < ApplicationRecord
  has_one :applicant, dependent: :destroy
  has_one :partner, dependent: :destroy

  has_many :people, dependent: :destroy
  has_many :addresses, through: :people

  scope :viewable, -> { where(status: ApplicationStatus.viewable_statuses) }

  enum status: ApplicationStatus.enum_values,
       _default: ApplicationStatus.enum_values[:initialised]

  def pretty_status
    status.titleize.upcase
  end
end
