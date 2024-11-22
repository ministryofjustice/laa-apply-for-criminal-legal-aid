class ApplicationSearchesController < ApplicationController
  helper_method :new_search_url, :search_url, :sorted_filter_params

  layout 'application_dashboard'

  def new
    @filter = ApplicationSearchFilter.new
  end

  def search
    set_search(default_sorting: { sort_by: 'submitted_at', sort_direction: 'descending' })
  end

  private

  def new_search_url
    return new_lkj123asdf_path unless FeatureFlags.search.enabled?

    new_application_searches_path
  end

  def search_url
    return search_lkj123asdf_path unless FeatureFlags.search.enabled?

    search_application_searches_path
  end

  def search_params
    params.permit(
      :page,
      :per_page,
      filter: [:search_text],
      sorting: ApplicationSearchSorting.attribute_names
    )
  end

  def sorted_filter_params
    { filter: @filter.params, sorting: @sorting.params }
  end

  def set_search(default_sorting: {})
    set_sorting(default_sorting)
    set_filter
    set_pagination

    @search = ApplicationSearch.new(
      filter: @filter, sorting: @sorting, pagination: @pagination
    )
  end

  def set_sorting(default = {})
    @sorting = ApplicationSearchSorting.new(search_params[:sorting] || default)
  end

  def set_filter
    @filter = ApplicationSearchFilter.new(search_text: search_params[:filter][:search_text],
                                          status: %w[submitted returned],
                                          office_code: current_office_code)
  end

  def set_pagination
    @pagination = Pagination.new(
      current_page: search_params[:page],
      limit_value: search_params[:per_page]
    )
  end
end
