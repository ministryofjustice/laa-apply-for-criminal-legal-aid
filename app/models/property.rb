class Property < ApplicationRecord
  belongs_to :crime_application

  attribute :value, :pence
  attribute :outstanding_mortgage, :pence

  store_accessor :address, :address_line_one, :address_line_two, :city, :country, :postcode

  OPTIONAL_ADDRESS_ATTRIBUTES = %w[address_line_two].freeze

  def complete?
    values_at(
      :property_type,
      :house_type,
      :bedrooms,
      :value,
      :outstanding_mortgage,
      :percentage_applicant_owned,
      :has_other_owners
    ).all?(&:present?)
  end
end
