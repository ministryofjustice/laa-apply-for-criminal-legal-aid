class SubmittedApplicationsController < ApplicationController
  before_action :check_crime_application_presence,
                :present_crime_application

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
