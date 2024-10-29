require 'laa_crime_schemas'

class ApplicationSearchFilter < ApplicationStruct
  include LaaCrimeSchemas::Types

  DATASTORE_FILTERS = %i[
    search_text
    status
    office_code
  ].freeze

  attribute? :search_text, Params::Nil | Params::String
  attribute? :status, Array.of(ApplicationStatus)
  attribute? :office_code, Params::String

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
