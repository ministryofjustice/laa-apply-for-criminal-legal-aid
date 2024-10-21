class ApplicationSearchFilter < ApplicationStruct
  DATASTORE_FILTERS = %i[
    search_text
    status
    office_code
  ].freeze

  attribute? :search_text, Types::Params::Nil | Types::Params::String
  attribute? :status, Types::Array.of(Types::ApplicationStatus)
  attribute? :office_code, Types::Params::String

  def datastore_params
    DATASTORE_FILTERS.each_with_object({}) do |filter, params|
      params.merge!(send(:"#{filter}_datastore_param"))
    end
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
