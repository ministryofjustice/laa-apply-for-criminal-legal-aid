class SubmittedApplicationsController < ApplicationController
  before_action :check_crime_application_presence,
                :present_crime_application, only: [:show]

  def index
    # TODO: to be implemented.
    #
    # My suggestion is we use this action to render the `submitted`
    # and `returned` listings. The default being `submitted` (we
    # scope the collection `CrimeApplication.submitted`), and optional
    # if a "status" query param is provided, we can filter by
    # `submitted` or `returned` to render one or the other list.
    #
    # Example of routes:
    # - /submitted/applications (renders `submitted` status tab)
    # - /submitted/applications?status=submitted (same as above)
    # - /submitted/applications?status=returned (renders `returned` tab)
    #
    # We don't have yet the `returned` status, and all this is really
    # a bit pointless as this controller will ONLY talk to the
    # document store through an API, but we don't have any of that yet.
  end

  def show
    @presenter = Summary::HtmlPresenter.new(
      crime_application: current_crime_application
    )
  end

  private

  # TODO: this will go to the document store when we have it.
  # For now we fake it, and get it from the local DB as we are
  # not purging applications on submission yet.
  #
  def current_crime_application
    @current_crime_application ||= CrimeApplication.submitted.find_by(id: params[:id])
  end

  def present_crime_application
    @crime_application = helpers.present(current_crime_application)
  end
end
