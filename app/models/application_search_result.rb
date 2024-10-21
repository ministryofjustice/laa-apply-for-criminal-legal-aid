class ApplicationSearchResult < ApplicationStruct
  attribute :applicant_name, Types::String
  attribute :submitted_at, Types::DateTime
  attribute :reference, Types::Integer
  attribute :resource_id, Types::Uuid
  attribute :status, Types::String
  attribute? :application_type, Types::ApplicationType
  attribute? :office_code, Types::String
  attribute? :provider_name, Types::String

  alias id resource_id

  def to_param
    id
  end
end
