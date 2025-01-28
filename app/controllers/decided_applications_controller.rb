class DecidedApplicationsController < CompletedApplicationsController
  include ApplicationSearchable

  def index
    set_search(
      default_filter: { review_status: ['assessment_completed'] },
      default_sorting: { sort_by: 'submitted_at', sort_direction: 'descending' }
    )
  end
end
