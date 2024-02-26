class Capital < ApplicationRecord
  belongs_to :crime_application
  attribute :premium_bonds_total_value, :pence
end
