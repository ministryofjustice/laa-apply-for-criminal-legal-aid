class Capital < ApplicationRecord
  attribute :premium_bonds_total_value, :pence

  belongs_to :crime_application
  has_many :savings, through: :crime_application
  has_many :investments, through: :crime_application
  has_many :national_savings_certificates, through: :crime_application
end
