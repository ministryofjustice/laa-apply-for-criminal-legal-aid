class Outgoings < ApplicationRecord
  belongs_to :crime_application
  has_many :outgoings_payments, through: :crime_application

  validate on: :submission do
    answers_validator.validate
  end

  def complete?
    valid?(:submission)
  end

  def answers_validator
    @answers_validator ||= OutgoingsAssessment::AnswersValidator.new(self)
  end
end
