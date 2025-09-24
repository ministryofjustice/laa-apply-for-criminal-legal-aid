class Outgoings < ApplicationRecord
  include MeansOwnershipScope
  include TypesOfOutgoings

  belongs_to :crime_application, touch: true
  has_many :outgoings_payments, through: :crime_application

  validate on: :submission do
    answers_validator.validate
  end

  def other_payments
    outgoings_payments.where(
      payment_type: OutgoingsPaymentType::OTHER_PAYMENT_TYPES.map(&:to_s)
    )
  end

  def complete?
    valid?(:submission)
  end

  def answers_validator
    @answers_validator ||= OutgoingsAssessment::AnswersValidator.new(record: self)
  end
end
