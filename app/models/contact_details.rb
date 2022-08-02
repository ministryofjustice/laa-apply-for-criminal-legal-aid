class ContactDetails < ApplicationRecord
  belongs_to :person

  ADDRESS_FIELDS = %i[
    address_line_one
    address_line_two
    city
    county
    postcode
  ].freeze

  store_accessor :home_address, ADDRESS_FIELDS, prefix: :home
  store_accessor :correspondence_address, ADDRESS_FIELDS, prefix: :correspondence
end
