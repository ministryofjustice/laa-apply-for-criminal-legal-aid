class SubmittedApplicationsController < CompletedApplicationsController
  include ApplicationSearchable

  # TODO: make sure office scopting happens!!!!

  def index
    set_search(
      default_filter: { review_status: %w[application_received ready_for_assessment] },
      default_sorting: { sort_by: 'submitted_at', sort_direction: 'descending' }
    )
  end
end
