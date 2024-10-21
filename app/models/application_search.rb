class ApplicationSearch
  def initialize(filter:, pagination:, sorting:)
    @pagination = pagination
    @filter = filter
    @sorting = sorting
  end

  def results
    @results ||= datastore_search_response.map do |result|
      ApplicationSearchResult.new(result)
    end
  end

  def total
    @total ||= pagination.total_count
  end

  def pagination
    Pagination.new(datastore_search_response.pagination)
  end

  attr_reader :sorting, :filter

  private

  include DatastoreApi::Traits::ApiRequest
  include DatastoreApi::Traits::PaginatedResponse

  def datastore_search_response
    @datastore_search_response ||= paginated_response(datastore_response)
  end

  def datastore_params
    {
      search: @filter.datastore_params,
      pagination: @pagination.datastore_params,
      sorting: @sorting.to_h
    }
  end

  def datastore_response
    http_client.post('/searches', datastore_params)
  end
end
