class Capital < ApplicationRecord
  include MeansOwnershipScope

  belongs_to :crime_application
  attribute :premium_bonds_total_value, :pence
  attribute :partner_premium_bonds_total_value, :pence
  attribute :trust_fund_amount_held, :pence
  attribute :trust_fund_yearly_dividend, :pence
  attribute :partner_trust_fund_amount_held, :pence
  attribute :partner_trust_fund_yearly_dividend, :pence
  has_many :savings, through: :crime_application
  has_many :investments, through: :crime_application
  has_many :national_savings_certificates, through: :crime_application
  has_many :properties, through: :crime_application

  validate on: :submission do
    answers_validator.validate
    confirmation_validator.validate
  end

  validate on: :check_answers do
    answers_validator.validate
  end

  def complete?
    valid?(:submission)
  end

  private

  def confirmation_validator
    @confirmation_validator ||= CapitalAssessment::ConfirmationValidator.new(self)
  end

  def answers_validator
    @answers_validator ||= CapitalAssessment::AnswersValidator.new(record: self)
  end
end
