class Pagination < ApplicationStruct
  DEFAULT_LIMIT_VALUE = 50
  DEFAULT_CURRENT_PAGE = 1

  attribute? :current_page, Types::Coercible::Integer.default(DEFAULT_CURRENT_PAGE)
  attribute? :limit_value, Types::Params::Integer.default(DEFAULT_LIMIT_VALUE)
  attribute? :total_pages, Types::Params::Integer
  attribute? :total_count, Types::Params::Integer

  def datastore_params
    {
      page: current_page,
      per_page: limit_value
    }
  end
end
