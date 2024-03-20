class Property < ApplicationRecord
  belongs_to :crime_application

  OTHER_HOUSE_TYPE = 'other'.freeze

  default_scope { order(created_at: :asc) }

  attribute :value, :pence
  attribute :outstanding_mortgage, :pence

  has_many :property_owners, dependent: :destroy do
    # :nocov:
    def complete
      select(&:complete?)
    end
    # :nocov:
  end

  accepts_nested_attributes_for :property_owners, allow_destroy: true

  store_accessor :address, :address_line_one, :address_line_two, :city, :country, :postcode

  OPTIONAL_ADDRESS_ATTRIBUTES = %w[address_line_two].freeze
  REQUIRED_ATTRIBUTES = {
    residential: [
      :property_type,
      :house_type,
      :bedrooms,
      :value,
      :outstanding_mortgage,
      :percentage_applicant_owned,
      :has_other_owners
    ],
    land: [
      :property_type,
      :size_in_acres,
      :usage,
      :value,
      :outstanding_mortgage,
      :percentage_applicant_owned,
      :has_other_owners
    ],
    commercial: [
      :property_type,
      :usage,
      :value,
      :outstanding_mortgage,
      :percentage_applicant_owned,
      :has_other_owners
    ]
  }.freeze

  # TODO: use proper partner policy once we have one.
  def include_partner?
    YesNoAnswer.new(crime_application.client_has_partner.to_s).yes?
  end

  def complete?
    values_at(REQUIRED_ATTRIBUTES[property_type.to_sym]).all?(&:present?)
  end
end
