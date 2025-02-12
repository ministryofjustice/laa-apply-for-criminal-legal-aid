class DecidedApplicationsController < CompletedApplicationsController
  include DatastoreApi::Sorting

  def index
    set_search(filter: { review_status: %w[assessment_completed] })
  end
end
