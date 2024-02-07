class IncomePayment < ApplicationRecord
  belongs_to :crime_application

  store_accessor :metadata, :details
end
