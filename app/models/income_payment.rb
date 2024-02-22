class IncomePayment < ApplicationRecord
  include Payable

  belongs_to :crime_application

  attribute :amount, :pence
  store_accessor :metadata, :details
end
