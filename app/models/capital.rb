class Capital < ApplicationRecord
  belongs_to :crime_application
  attribute :premium_bonds_total_value, :pence
  attribute :trust_fund_amount_held, :pence
  attribute :trust_fund_yearly_dividend, :pence
  has_many :savings, through: :crime_application
  has_many :investments, through: :crime_application
  has_many :national_savings_certificates, through: :crime_application
  has_many :properties, through: :crime_application

  validates_with CapitalAssessment::AnswersValidator, on: [:submission, :check_answers]
  validates_with CapitalAssessment::ConfirmationValidator, on: :submission
end
