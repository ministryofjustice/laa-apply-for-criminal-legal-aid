module CrimeApplicationsHelper
  def sort_direction_name
    return 'asc' unless params[:order] == 'applicant_name'

    params[:sort] == 'desc' ? 'asc' : 'desc'
  end

  def sort_direction_created_at
    return 'asc' unless [nil, 'created_at'].include? params[:order]

    params[:sort] == 'asc' ? 'desc' : 'asc'
  end

  def aria_sort(column)
    return 'none' unless params[:order] == column

    params[:sort]
  end
end
