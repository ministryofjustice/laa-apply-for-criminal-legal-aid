class SubmittedApplicationsController < CompletedApplicationsController
  include DatastoreApi::SortedResults

  def index
    set_search(filter:)
  end

  private

  def filter
    return { status: %w[submitted returned] } unless FeatureFlags.decided_applications_tab.enabled?

    { review_status: %w[application_received ready_for_assessment] }
  end
end
