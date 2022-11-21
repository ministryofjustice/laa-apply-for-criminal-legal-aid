module StructTypes
  include Dry.Types()

  # NOTE: not coupling these enums to their value-objects
  # as we might want to extract all this to a gem
  APPLICATION_STATUS = %w[
    submitted
    returned
  ].freeze

  CORRESPONDENCE_ADDRESS_TYPES = %w[
    other_address
    home_address
    providers_office_address
  ].freeze

  ApplicationStatus = String.enum(*APPLICATION_STATUS)
  CorrespondenceAddressType = String.enum(*CORRESPONDENCE_ADDRESS_TYPES)

  SchemaVersion = Coercible::Float
  ApplicationReference = Coercible::Integer
end
