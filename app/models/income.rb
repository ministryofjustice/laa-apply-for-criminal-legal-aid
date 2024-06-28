class Income < ApplicationRecord
  include MeansOwnershipScope
  include PersonEmployments

  belongs_to :crime_application
  has_many :income_payments, through: :crime_application
  has_many :income_benefits, through: :crime_application
  has_many :dependants, through: :crime_application
  has_many :businesses, through: :crime_application

  attribute :applicant_self_assessment_tax_bill_amount, :pence
  attribute :partner_self_assessment_tax_bill_amount, :pence

  validate on: :submission do
    answers_validator.validate
  end

  def employments
    return [] unless known_to_be_full_means?

    crime_application.employments.where(ownership_type: employment_ownership_types)
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

  def partner_employment_income
    return nil if known_to_be_full_means? || partner.blank?
    return nil unless MeansStatus.include_partner?(crime_application)
    return nil unless partner_employed?

    partner.income_payments.employment
  end

  def client_employment_income
    return nil if known_to_be_full_means? || applicant.blank?
    return nil unless client_employed?

    applicant.income_payments.employment
  end

  private

  delegate :partner, :applicant, to: :crime_application

  def known_to_be_full_means?
    MeansStatus.full_means_required?(crime_application)
  rescue Errors::CannotYetDetermineFullMeans
    false
  end

  def employment_ownership_types
    scopes = []

    scopes << OwnershipType::APPLICANT.to_s if client_employed?
    scopes << OwnershipType::PARTNER.to_s if partner_employed?

    scopes & ownership_types
  end

  def partner_employed?
    partner_employment_status.include? EmploymentStatus::EMPLOYED.to_s
  end

  def client_employed?
    employment_status.include? EmploymentStatus::EMPLOYED.to_s
  end
end
