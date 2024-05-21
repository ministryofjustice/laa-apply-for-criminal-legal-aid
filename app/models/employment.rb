class Employment < ApplicationRecord
  store_accessor :metadata,
                 [:before_or_after_tax]

  belongs_to :crime_application

  store_accessor :address, :address_line_one, :address_line_two, :city, :country, :postcode
end
