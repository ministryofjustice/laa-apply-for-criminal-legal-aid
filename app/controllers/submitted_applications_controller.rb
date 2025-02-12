class SubmittedApplicationsController < CompletedApplicationsController
  include DatastoreApi::Sorting

  def index
    set_search(filter:)
  end

  private

  def filter
    return { status: %w[submitted returned] } if FeatureFlags.decided_applications_tab.disabled?

    { review_status: %w[application_received ready_for_assessment] }
  end
end
