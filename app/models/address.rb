class Address < ApplicationRecord
  ADDRESS_ATTRIBUTES = %i[
    address_line_one
    address_line_two
    postcode
    city
    country
  ].freeze

  belongs_to :person
end
