class SubmittedApplicationsController < CompletedApplicationsController
  include DatastoreApi::SortedResults

  def index
    set_search(filter: { review_status: %w[application_received ready_for_assessment] })
  end
end
