class ReturnedApplicationsController < DashboardController
  include ApplicationSearchable
  layout 'application_dashboard'

  def index
    set_search(
      default_filter: { status: ['returned'] },
      default_sorting: { sort_by: 'reviewed_at', sort_direction: 'descending' }
    )
  end
end
