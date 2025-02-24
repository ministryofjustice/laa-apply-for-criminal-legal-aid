class DecidedApplicationsController < CompletedApplicationsController
  include DatastoreApi::SortedResults

  def index
    set_search(filter: { review_status: %w[assessment_completed] })
  end
end
