class ApplicationSearchResult
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :applicant_name, :string
  attribute :submitted_at, :datetime
  attribute :reference, :integer
  attribute :resource_id, :string
  attribute :status, :string
  attribute :application_type, :string
  attribute :office_code, :string
  attribute :provider_name, :string
  attribute :review_status, :string

  alias id resource_id

  def to_param
    id
  end
end
