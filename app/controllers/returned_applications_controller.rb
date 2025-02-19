class ReturnedApplicationsController < CompletedApplicationsController
  include DatastoreApi::SortedResults

  def index
    set_search(filter: { status: %w[returned] })
  end
end
