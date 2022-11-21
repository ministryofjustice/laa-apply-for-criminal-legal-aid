module Structs
  class CrimeApplication < ApplicationStruct
    attribute :id, StructTypes::String
    attribute :schema_version, StructTypes::SchemaVersion
    attribute :reference, StructTypes::ApplicationReference
    attribute :created_at, StructTypes::JSON::DateTime
    attribute :submitted_at, StructTypes::JSON::DateTime
    attribute :date_stamp, StructTypes::JSON::DateTime
    attribute :status, StructTypes::ApplicationStatus

    attribute :client_details, ClientDetails
  end
end
