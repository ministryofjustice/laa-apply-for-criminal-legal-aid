class Income < ApplicationRecord
  include MeansOwnershipScope
  include EmployedIncome
  include SelfEmployedIncome

  belongs_to :crime_application
  has_many :dependants, through: :crime_application

  attribute :applicant_self_assessment_tax_bill_amount, :pence
  attribute :partner_self_assessment_tax_bill_amount, :pence

  validate on: :submission do
    answers_validator.validate
  end

  def employments
    return [] unless known_to_be_full_means?

    crime_application.employments.where(ownership_type: ownership_types & employed_owners)
  end

  def businesses
    @businesses ||= crime_application.businesses.where(
      ownership_type: ownership_types & self_employed_owners
    )
  end

  def income_payments
    return @income_payments if @income_payments

    # disregard payments for people not included in means assessemnt
    # as well as obsolete payment types
    scope = crime_application.income_payments
                             .owned_by(ownership_types)
                             .not_of_type(obsolete_employed_income_payment_types)

    # disregard employed income for people no longer employed
    if not_working_owners.present?
      scope = scope.where('NOT (ownership_type IN(?) AND payment_type IN(?))',
                          not_working_owners, employed_income_payment_types)
    end

    @income_payments = scope
  end

  def income_benefits
    @income_benefits ||= crime_application.income_benefits.where(
      ownership_type: ownership_types
    )
  end

  def applicant_self_assessment_tax_bill
    return unless client_employed? || client_self_employed?

    super if known_to_be_full_means?
  end

  def partner_self_assessment_tax_bill
    return unless partner_employed? || partner_self_employed?
    return unless MeansStatus.include_partner?(crime_application)

    super if known_to_be_full_means?
  end

  def applicant_other_work_benefit_received
    return unless client_employed? || client_self_employed?

    super if known_to_be_full_means?
  end

  def partner_other_work_benefit_received
    return unless partner_employed? || partner_self_employed?
    return unless MeansStatus.include_partner?(crime_application)

    super if known_to_be_full_means?
  end

  def manage_without_income
    return if all_income_over_zero?

    super
  end

  def complete?
    valid?(:submission)
  end

  def answers_validator
    @answers_validator ||= IncomeAssessment::AnswersValidator.new(record: self)
  end

  def all_income_over_zero?
    all_income_total > 0 # rubocop:disable Style/NumericPredicate
  end

  def all_income_total
    income_payments.sum { |p| p.amount.to_i } + income_benefits.sum { |p| p.amount.to_i } + employments_total
  end

  def employments_total
    employments&.sum { |e| e.amount.to_i }
  end

  def known_to_be_full_means?
    MeansStatus.full_means_required?(crime_application)
  rescue Errors::CannotYetDetermineFullMeans
    false
  end

  def client_in_armed_forces
    return unless require_client_in_armed_forces?

    super
  end

  def partner_in_armed_forces
    return unless require_partner_in_armed_forces?

    super
  end

  delegate :partner, :applicant, to: :crime_application

  private

  def not_working_owners
    OwnershipType.exclusive.map(&:to_s) - (employed_owners | self_employed_owners)
  end
end
