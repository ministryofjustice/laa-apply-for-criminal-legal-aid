class Address < ApplicationRecord
  ADDRESS_ATTRIBUTES = %i[
    address_line_one
    address_line_two
    city
    postcode
    country
  ].freeze

  belongs_to :person, touch: true
end
