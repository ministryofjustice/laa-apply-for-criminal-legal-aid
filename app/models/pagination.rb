require 'laa_crime_schemas'

class Pagination < ApplicationStruct
  include LaaCrimeSchemas::Types

  DEFAULT_LIMIT_VALUE = 50
  DEFAULT_CURRENT_PAGE = 1

  attribute? :current_page, Coercible::Integer.default(DEFAULT_CURRENT_PAGE)
  attribute? :limit_value, Params::Integer.default(DEFAULT_LIMIT_VALUE)
  attribute? :total_pages, Params::Integer
  attribute? :total_count, Params::Integer

  def datastore_params
    {
      page: current_page,
      per_page: limit_value
    }
  end
end
