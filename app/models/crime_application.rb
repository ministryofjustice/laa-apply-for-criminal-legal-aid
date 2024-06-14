class CrimeApplication < ApplicationRecord
  include TypeOfApplication
  include Passportable

  attr_readonly :application_type
  attribute :date_stamp, :datetime

  has_one :case, dependent: :destroy
  alias kase case

  has_one :applicant, dependent: :destroy
  has_one :partner, dependent: :destroy
  has_one :income, dependent: :destroy
  has_one :outgoings, dependent: :destroy
  has_one :capital, dependent: :destroy
  has_one :partner_detail, dependent: :destroy

  has_many :people, dependent: :destroy
  has_many :documents, dependent: :destroy

  has_many :income_payments, dependent: :destroy
  accepts_nested_attributes_for :income_payments, allow_destroy: true

  has_many :outgoings_payments, dependent: :destroy
  accepts_nested_attributes_for :outgoings_payments, allow_destroy: true

  has_many :income_benefits, dependent: :destroy
  accepts_nested_attributes_for :income_benefits, allow_destroy: true

  # NOTE: Useful for testing, use carefully in logic
  has_many :payments, dependent: :destroy

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

  has_many(:client_employments,
           -> { where(ownership_type: OwnershipType::APPLICANT.to_s).order(created_at: :asc) },
           inverse_of: :crime_application,
           class_name: 'Employment',
           dependent: :destroy)

  has_many(:partner_employments,
           -> { where(ownership_type: OwnershipType::PARTNER.to_s).order(created_at: :asc) },
           inverse_of: :crime_application,
           class_name: 'Employment',
           dependent: :destroy)

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

  validate on: :client_details do
    ::ClientDetails::AnswersValidator.new(record: self, crime_application: self)
                                     .validate
  end

  validate on: :passporting_benefit do
    ::PassportingBenefitCheck::AnswersValidator.new(self).validate
  end

  validate on: :submission_review, unless: :post_submission_evidence? do
    ::SectionsCompletenessValidator.new(self).validate
  end

  def client_details_complete?
    valid?(:client_details)
  end

  def passporting_benefit_complete?
    valid?(:passporting_benefit)
  end

  def applicant_requires_nino_evidence?
    # the applicant is over 18 and no NINO has been entered
    # plus any one or more of the following apply:
    # - they are passported on means
    # - they receive any non-passporting benefit
    # - the case type is `indictable` or `already_in_crown_court`
    return false unless applicant_18_or_over_at_date_stamp? && applicant&.nino.blank?

    case_types = [
      CaseType::INDICTABLE.to_s,
      CaseType::ALREADY_IN_CROWN_COURT.to_s
    ]

    applicant.has_passporting_benefit? || case_types.include?(self.case&.case_type) || income_benefits.any?
  end

  # rubocop:disable Metrics/AbcSize
  def applicant_18_or_over_at_date_stamp?
    return false if applicant.blank?
    return !applicant.under18? if date_stamp.nil?

    dob = applicant&.date_of_birth
    temp_date_stamp = date_stamp&.to_date

    age = temp_date_stamp.year - dob.year - (dob.change(year: temp_date_stamp.year) > temp_date_stamp ? 1 : 0)
    age >= 18
  end
  # rubocop:enable Metrics/AbcSize
end
