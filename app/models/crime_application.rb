class CrimeApplication < ApplicationRecord
  has_one :case, dependent: :destroy

  has_one :applicant, dependent: :destroy
  has_one :partner, dependent: :destroy

  has_many :people, dependent: :destroy

  # Shortcuts through intermediate tables
  has_one :ioj, through: :case
  has_many :addresses, through: :people
  has_many :codefendants, through: :case

  enum status: ApplicationStatus.enum_values

  alias_attribute :reference, :usn

  store_accessor :provider_details,
                 :provider_email,
                 :legal_rep_first_name,
                 :legal_rep_last_name,
                 :legal_rep_telephone
end
