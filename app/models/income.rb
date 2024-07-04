class Income < ApplicationRecord
  include MeansOwnershipScope
  include EmployedIncome

  belongs_to :crime_application
  has_many :dependants, through: :crime_application
  has_many :businesses, through: :crime_application

  attribute :applicant_self_assessment_tax_bill_amount, :pence
  attribute :partner_self_assessment_tax_bill_amount, :pence

  validate on: :submission do
    answers_validator.validate
  end

  def employments
    return [] unless known_to_be_full_means?

    crime_application.employments.where(ownership_type: ownership_types & employed_owners)
  end

  def income_payments
    return @income_payments if @income_payments

    # disregard payments for people not included in means assessemnt
    # as well as obsolete payment types
    scope = crime_application.income_payments
                             .owned_by(ownership_types)
                             .not_of_type(obsolete_employed_income_payment_types)

    # disregard employed income for people no longer employed
    if not_employed_owners.present?
      scope = scope.where('NOT (ownership_type IN(?) AND payment_type IN(?))',
                          not_employed_owners, employed_income_payment_types)
    end

    @income_payments = scope
  end

  def income_benefits
    @income_benefits ||= crime_application.income_benefits.where(
      ownership_type: ownership_types
    )
  end

  def applicant_self_assessment_tax_bill
    super if client_employed? && known_to_be_full_means?
  end

  def partner_self_assessment_tax_bill
    super if partner_employed? && known_to_be_full_means? && MeansStatus.include_partner?(crime_application)
  end

  def applicant_other_work_benefit_received
    super if client_employed? && known_to_be_full_means?
  end

  def partner_other_work_benefit_received
    super if partner_employed? && known_to_be_full_means? && MeansStatus.include_partner?(crime_application)
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

  def partner_employed?
    partner_employment_status.include? EmploymentStatus::EMPLOYED.to_s
  end

  def client_employed?
    employment_status.include? EmploymentStatus::EMPLOYED.to_s
  end

  def known_to_be_full_means?
    MeansStatus.full_means_required?(crime_application)
  rescue Errors::CannotYetDetermineFullMeans
    false
  end

  delegate :partner, :applicant, to: :crime_application
end
