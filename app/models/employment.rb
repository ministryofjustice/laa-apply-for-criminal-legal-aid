class Employment < ApplicationRecord
  belongs_to :crime_application

  store_accessor :address, :address_line_one, :address_line_two, :city, :country, :postcode
end
