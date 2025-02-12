module ApplicationSearchable
  extend ActiveSupport::Concern

  private

  def search_params
    params.permit(
      :page,
      :per_page,
      filter: ApplicationSearchFilter.attribute_names,
      sorting: ApplicationSearchSorting.attribute_names
    )
  end

  def set_search(default_filter: {}, default_sorting: {})
    set_sorting(default_sorting)
    set_filter(default_filter)
    set_pagination

    @search = ApplicationSearch.new(
      filter: @filter, sorting: @sorting, pagination: @pagination
    )
  end

  def set_sorting(default = {})
    @sorting = ApplicationSearchSorting.new(search_params[:sorting] || default)
  end

  def set_filter(default = {})
    @filter = ApplicationSearchFilter.new(search_params[:filter] || default)
  end

  def set_pagination
    @pagination = Pagination.new(
      current_page: search_params[:page],
      limit_value: search_params[:per_page]
    )
  end
end
