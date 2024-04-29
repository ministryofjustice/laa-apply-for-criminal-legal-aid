class CrimeApplication < ApplicationRecord
  include TypeOfApplication
  include Passportable

  attr_readonly :application_type
  attribute :date_stamp, :string

  has_one :case, dependent: :destroy
  alias kase case

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

  def applicant_requires_nino_evidence?
    # the applicant is over 18 and no NINO has been entered
    # plus any one or more of the following apply:
    # - they are passported on means
    # - they receive any non-passporting benefit
    # - the case type is `indictable` or `already_in_crown_court`
    return false unless applicant_18_or_over? && applicant&.nino.blank?

    case_types = [
      CaseType::INDICTABLE.to_s,
      CaseType::ALREADY_IN_CROWN_COURT.to_s
    ]

    applicant.benefit_type.present? || case_types.include?(self.case.case_type) || income_benefits.any?
  end

  def applicant_18_or_over?
    return false if date_stamp.nil? || applicant.blank?

    dob = applicant&.date_of_birth
    date_stamp = self.date_stamp&.to_date

    age = date_stamp.year - dob.year - (dob.change(year: date_stamp.year) > date_stamp ? 1 : 0)
    age >= 18
  end
end
