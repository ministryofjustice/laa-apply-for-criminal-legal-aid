class IncomePayment < ApplicationRecord
  belongs_to :crime_application

  store_accessor :details, :other_sources_description
end
