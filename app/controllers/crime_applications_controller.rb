class CrimeApplicationsController < ApplicationController
  def index
    # TODO: scope will change as we know more
    @applications = CrimeApplication.joins(:people).includes(:applicant).merge(Applicant.with_name)
  end

  def edit
    @tasklist = TaskList::Collection.new(
      view_context, crime_application: crime_application
    )
  end

  private

  # NOTE: once we have applications linked to each provider, this
  # needs to be scoped to the currently signed in provider
  def crime_application
    CrimeApplication.find(params.require(:id))
  end
end
