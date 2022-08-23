class CrimeApplication < ApplicationRecord
  has_one :applicant, dependent: :destroy
  has_one :partner, dependent: :destroy

  has_many :people, dependent: :destroy
  has_many :addresses, through: :people

  enum status: ApplicationStatus.enum_values,
       _default: ApplicationStatus.enum_values[:initialised]
end
