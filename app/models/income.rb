class Income < ApplicationRecord
  belongs_to :crime_application
  has_many :income_payments, through: :crime_application
  has_many :income_benefits, through: :crime_application
  has_many :dependants, through: :crime_application

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
    income_payments.sum { |p| p.amount.to_i } + income_benefits.sum { |p| p.amount.to_i }
  end
end
