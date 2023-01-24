module DashboardHelper
  def status_filter
    if controller.controller_name == 'completed_applications'
      allowed_statuses = [
        ApplicationStatus::SUBMITTED, ApplicationStatus::RETURNED
      ].map(&:to_s)

      allowed_statuses.include?(params[:q]) ? params[:q] : allowed_statuses.first
    else
      ApplicationStatus::IN_PROGRESS.to_s
    end
  end

  def sort_by
    sort_by_allowed? ? params[:sort_by] : sortable_columns.first
  end

  def sort_direction
    sort_direction_allowed? ? params[:sort_direction] : 'desc'
  end

  def sort_by_allowed?
    sortable_columns.include?(params[:sort_by])
  end

  def sort_direction_allowed?
    %w[asc desc].include?(params[:sort_direction])
  end

  def flipped_sort_direction
    sort_direction == 'asc' ? 'desc' : 'asc'
  end

  # https://developer.mozilla.org/en-US/docs/Web/Accessibility/ARIA/Attributes/aria-sort
  def aria_sort(column)
    if sort_by == column
      { 'asc' => 'ascending', 'desc' => 'descending' }.fetch(sort_direction)
    else
      'none'
    end
  end

  # rubocop:disable Metrics/CyclomaticComplexity
  def aria_current_page(status)
    case status
    when :in_progress
      'page' if current_page?(controller: :crime_applications, action: :index)
    when :submitted
      'page' if current_page?(controller: :completed_applications, action: :index) && (status_filter != 'returned')
    when :returned
      'page' if current_page?(controller: :completed_applications, action: :index) && (status_filter == 'returned')
    end
  end
  # rubocop:enable Metrics/CyclomaticComplexity
end
