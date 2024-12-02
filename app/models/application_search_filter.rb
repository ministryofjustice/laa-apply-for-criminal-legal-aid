class ApplicationSearchFilter
  include ActiveModel::Model
  include ActiveModel::Attributes

  DATASTORE_FILTERS = %i[
    search_text
    status
    office_code
  ].freeze

  attribute :search_text, :string
  attribute :office_code, :string
  attribute :status, array: true

  def datastore_params
    DATASTORE_FILTERS.each_with_object({}) do |filter, params|
      params.merge!(send(:"#{filter}_datastore_param"))
    end
  end

  def to_partial_path
    'application_search_filter'
  end

  def params
    {
      search_text:
    }
  end

  private

  def search_text_datastore_param
    { search_text: }
  end

  def status_datastore_param
    { status: }
  end

  def office_code_datastore_param
    { office_code: }
  end
end
