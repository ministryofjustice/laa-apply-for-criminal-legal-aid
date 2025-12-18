class CrimeApplication < ApplicationRecord # rubocop:disable Metrics/ClassLength
  include TypeOfApplication
  include Passportable
  include MeansOwnershipScope

  after_create :publish_creation_event
  before_destroy :check_deletion_exemption
  after_touch :publish_update_event

  attr_readonly :application_type
  attribute :date_stamp, :datetime
  attribute :date_stamp_context, Type::DateStampContextType.new

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

  has_many(:income_payments,
           inverse_of: :crime_application,
           dependent: :destroy)
  accepts_nested_attributes_for :income_payments, allow_destroy: true

  has_many(:income_benefits,
           inverse_of: :crime_application,
           dependent: :destroy)
  accepts_nested_attributes_for :income_benefits, allow_destroy: true

  has_many(:outgoings_payments,
           inverse_of: :crime_application,
           dependent: :destroy)
  accepts_nested_attributes_for :outgoings_payments, allow_destroy: true

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

  has_many(:employments, inverse_of: :crime_application, dependent: :destroy)

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

  has_many(:businesses, inverse_of: :crime_application, dependent: :destroy)

  enum :status, ApplicationStatus.enum_values

  scope :active, -> { where(soft_deleted_at: nil) }

  scope :with_applicant, -> { joins(:people).includes(:applicant).merge(Applicant.with_name) }

  scope :to_be_soft_deleted, lambda {
    active.where.not(application_type: ApplicationType::POST_SUBMISSION_EVIDENCE.to_s)
          .where(exempt_from_deletion: false, parent_id: nil, updated_at: ..Rails.configuration.x.retention_period.ago)
  }

  scope :to_be_hard_deleted, lambda {
    where(soft_deleted_at: ..Rails.configuration.x.soft_deletion_period.ago)
  }

  alias_attribute :reference, :usn

  store_accessor :provider_details,
                 :legal_rep_has_partner_declaration,
                 :legal_rep_no_partner_declaration_reason,
                 :provider_email,
                 :legal_rep_first_name,
                 :legal_rep_last_name,
                 :legal_rep_telephone

  # Before submitting the application we run a final
  # validation to ensure some key details are fulfilled
  validates_with ApplicationFulfilmentValidator, on: :submission, unless: :post_submission_evidence?
  validates_with PseFulfilmentValidator, on: :submission, if: :post_submission_evidence?

  validate on: :client_details do
    ::ClientDetails::AnswersValidator.new(record: self, crime_application: self).validate
  end

  validate on: :passporting_benefit do
    ::PassportingBenefitCheck::AnswersValidator.new(self).validate
  end

  validate on: :submission_review, unless: :post_submission_evidence? do
    ::SectionsCompletenessValidator.new(self).validate
  end

  # Ignore any stored date_stamp if the application is not date_stampable
  def date_stamp
    return super if not_means_tested?
    return if kase&.case_type.blank?
    return unless CaseType.new(kase.case_type).date_stampable?

    super
  end

  def client_details_complete?
    valid?(:client_details)
  end

  def passporting_benefit_complete?
    valid?(:passporting_benefit)
  end

  def draft_submission
    draft = SubmissionSerializer::Application.new(self).to_builder
    draft.set!('status', ApplicationStatus::IN_PROGRESS.to_s)

    Adapters::Structs::CrimeApplication.new(draft.attributes!.as_json)
  end

  def review_status
    nil
  end

  def exempt_from_deletion!
    self.soft_deleted_at = nil
    self.exempt_from_deletion = true
    save!
  end

  private

  def check_deletion_exemption
    return unless exempt_from_deletion?

    raise ActiveRecord::RecordNotDestroyed, 'Application exempt from deletion'
  end

  def publish_update_event
    Datastore::Events::DraftUpdated.new(entity_id: id,
                                        entity_type: application_type,
                                        business_reference: reference).call
  end

  def publish_creation_event
    Datastore::Events::DraftCreated.new(entity_id: id,
                                        entity_type: application_type,
                                        business_reference: reference).call
  end
end
