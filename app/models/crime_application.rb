class CrimeApplication < ApplicationRecord
  include TypeOfApplication
  include Passportable

  attr_readonly :application_type

  has_one :case, dependent: :destroy

  has_one :applicant, dependent: :destroy
  has_one :partner, dependent: :destroy
  has_one :income, dependent: :destroy
  has_one :outgoings, dependent: :destroy
  has_one :capital, dependent: :destroy

  has_many :people, dependent: :destroy
  has_many :documents, dependent: :destroy

  has_many :income_payments, dependent: :destroy
  accepts_nested_attributes_for :income_payments, allow_destroy: true

  has_many :outgoings_payments, dependent: :destroy
  accepts_nested_attributes_for :outgoings_payments, allow_destroy: true

  has_many :income_benefits, dependent: :destroy
  accepts_nested_attributes_for :income_benefits, allow_destroy: true

  has_many :dependants, dependent: :destroy
  accepts_nested_attributes_for :dependants, allow_destroy: true

  has_many(:properties,
           -> { order(created_at: :asc) },
           inverse_of: :crime_application,
           dependent: :destroy)

  has_many(:savings,
           -> { order(created_at: :asc) },
           inverse_of: :crime_application,
           dependent: :destroy)

  has_many(:investments,
           -> { order(created_at: :asc) },
           inverse_of: :crime_application,
           dependent: :destroy)

  has_many(:national_savings_certificates,
           -> { order(created_at: :asc) },
           inverse_of: :crime_application,
           dependent: :destroy)

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
  validates_with ApplicationFulfilmentValidator, on: :submission, unless: :post_submission_evidence?
  validates_with PseFulfilmentValidator, on: :submission, if: :post_submission_evidence?
end
