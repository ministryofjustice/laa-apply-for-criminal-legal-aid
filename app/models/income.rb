class Income < ApplicationRecord
  include MeansOwnershipScope

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
    crime_application.employments&.sum { |e| e.amount.to_i }
  end

  def ownership_types
    if MeansStatus.include_partner?(crime_application)
      [OwnershipType::APPLICANT.to_s, OwnershipType::PARTNER.to_s]
    else
      [OwnershipType::APPLICANT.to_s]
    end
  end

  def reset_client_employment_fields!
    update!(
      applicant_self_assessment_tax_bill: nil,
      applicant_self_assessment_tax_bill_amount: nil,
      applicant_self_assessment_tax_bill_frequency: nil,
      applicant_other_work_benefit_received: nil,
    )
  end

  def reset_partner_employment_fields!
    update!(
      partner_self_assessment_tax_bill: nil,
      partner_self_assessment_tax_bill_amount: nil,
      partner_self_assessment_tax_bill_frequency: nil,
      partner_other_work_benefit_received: nil,
    )
  end
end
