class ApplicationSearchFilter
  include ActiveModel::Model
  include ActiveModel::Attributes

  DATASTORE_FILTERS = %i[
    search_text
    status
    review_status
    office_code
  ].freeze

  attribute :search_text, :string
  attribute :office_code, :string
  attribute :status, array: true
  attribute :review_status, array: true

  def datastore_params
    raise Errors::UnscopedDatastoreQuery unless office_code

    {
      search_text:,
      review_status:,
      status:,
      office_code:,
    }
  end

  def to_partial_path
    'application_search_filter'
  end

  def params
    { search_text: }
  end
end
