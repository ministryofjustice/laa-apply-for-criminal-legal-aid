class IncomeBenefit < ApplicationRecord
  belongs_to :crime_application

  attribute :amount, :pence
  store_accessor :metadata, :details
end
