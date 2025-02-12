class ReturnedApplicationsController < CompletedApplicationsController
  include DatastoreApi::Sorting

  def index
    set_search(filter: { status: %w[returned] })
  end
end
