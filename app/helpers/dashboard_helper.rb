module DashboardHelper
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
