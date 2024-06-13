class Income < ApplicationRecord
  belongs_to :crime_application
  has_many :income_payments, through: :crime_application
  has_many :income_benefits, through: :crime_application
  has_many :dependants, through: :crime_application

  attribute :applicant_self_assessment_tax_bill_amount, :pence

  validate on: :submission do
    answers_validator.validate
  end

  def complete?
    valid?(:submission)
  end

  def answers_validator
    @answers_validator ||= IncomeAssessment::AnswersValidator.new(record: self)
  end
end
