class CrimeApplication < ApplicationRecord
  has_one :case, dependent: :destroy

  has_one :applicant, dependent: :destroy
  has_one :partner, dependent: :destroy

  has_many :people, dependent: :destroy

  # Shortcuts through intermediate tables
  has_many :addresses, through: :people
  has_many :codefendants, through: :case

  enum status: ApplicationStatus.enum_values,
       _default: ApplicationStatus.enum_values[:in_progress]

  alias_attribute :reference, :usn
end
