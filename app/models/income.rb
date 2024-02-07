class Income < ApplicationRecord
  belongs_to :crime_application
  attribute :council_tax_amount, :money
end
