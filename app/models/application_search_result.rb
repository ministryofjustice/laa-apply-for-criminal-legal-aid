require 'laa_crime_schemas'

class ApplicationSearchResult < ApplicationStruct
  include LaaCrimeSchemas::Types

  attribute :applicant_name, String
  attribute :submitted_at, JSON::DateTime | Nominal::DateTime
  attribute :reference, Integer
  attribute :resource_id, Strict::String
  attribute :status, String
  attribute? :application_type, ApplicationType
  attribute? :office_code, String
  attribute? :provider_name, String

  alias id resource_id

  def to_param
    id
  end
end
