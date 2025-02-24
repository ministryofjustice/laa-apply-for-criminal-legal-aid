module DatastoreApi
  module SortedResults
    extend ActiveSupport::Concern

    included do
      helper_method :sorted_filter_params
    end

    private

    def search_params
      params.permit(
        :page,
        :per_page,
        sorting: ApplicationSearchSorting.attribute_names
      )
    end

    def set_search(filter:, default_sorting: {})
      set_sorting(default_sorting)

      @filter = ApplicationSearchFilter.new(
        filter.merge(office_code: current_office_code)
      )

      set_pagination

      @search = ApplicationSearch.new(
        filter: @filter, sorting: @sorting, pagination: @pagination
      )
    end

    def set_sorting(default = {})
      @sorting = ApplicationSearchSorting.new(search_params[:sorting] || default)
    end

    def sorted_filter_params
      { sorting: @sorting.params }
    end

    def set_pagination
      @pagination = Pagination.new(
        current_page: search_params[:page],
        limit_value: search_params[:per_page]
      )
    end
  end
end
