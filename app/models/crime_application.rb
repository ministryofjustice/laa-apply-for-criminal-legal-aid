class CrimeApplication < ApplicationRecord
  include Passportable

  has_one :case, dependent: :destroy

  has_one :applicant, dependent: :destroy
  has_one :partner, dependent: :destroy
  has_one :income, dependent: :destroy

  has_many :people, dependent: :destroy
  has_many :documents, dependent: :destroy

  # Shortcuts through intermediate tables
  has_one :ioj, through: :case
  has_many :addresses, through: :people
  has_many :codefendants, through: :case

  enum status: ApplicationStatus.enum_values

  scope :with_applicant, -> { joins(:people).includes(:applicant).merge(Applicant.with_name) }

  alias_attribute :reference, :usn

  store_accessor :provider_details,
                 :provider_email,
                 :legal_rep_first_name,
                 :legal_rep_last_name,
                 :legal_rep_telephone

  # Before submitting the application we run a final
  # validation to ensure some key details are fulfilled
  validates_with ApplicationFulfilmentValidator, on: :submission
end
