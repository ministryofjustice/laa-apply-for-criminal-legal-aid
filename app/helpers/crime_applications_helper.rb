module CrimeApplicationsHelper
  def sort_direction
    return 'asc' unless [nil, 'created_at', 'submitted_at', 'returned_at'].include? params[:order]

    params[:sort] == 'asc' ? 'desc' : 'asc'
  end

  def aria_sort(column)
    return 'none' unless params[:order] == column

    params[:sort]
  end
end
