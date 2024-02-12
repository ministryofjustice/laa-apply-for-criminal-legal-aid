class Outgoings < ApplicationRecord
  belongs_to :crime_application
  attribute :council_tax_amount, :pence
end
