require 'laa_crime_schemas/types/types'
require 'dry-schema'

module Types
  include LaaCrimeSchemas::Types

  Uuid = Strict::String

  # Uuid = Strict::String.constrained(
  #   format: /\A[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-4[0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}\z/i
  # )

  PhoneNumber = String
  Date = Date | JSON::Date
  DateTime = JSON::DateTime | Nominal::DateTime
end
