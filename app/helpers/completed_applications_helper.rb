module CompletedApplicationsHelper
  def sort_direction_submitted_at
    return 'asc' unless [nil, 'submitted_at', 'returned_at'].include? params[:order]

    params[:sort] == 'asc' ? 'desc' : 'asc'
  end
end
