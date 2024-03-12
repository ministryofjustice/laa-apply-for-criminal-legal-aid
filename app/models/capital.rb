class Capital < ApplicationRecord
  belongs_to :crime_application
  attribute :premium_bonds_total_value, :pence
  has_many :savings, through: :crime_application
  has_many :investments, through: :crime_application
end
