class Capital < ApplicationRecord
  belongs_to :crime_application
  attribute :premium_bonds_total_value, :pence
  attribute :trust_fund_amount_held, :pence
  attribute :yearly_dividend, :pence
  has_many :savings, through: :crime_application
  has_many :investments, through: :crime_application
  has_many :national_savings_certificates, through: :crime_application
  has_many :properties, through: :crime_application
end
