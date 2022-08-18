class CrimeApplicationsController < ApplicationController
  def index
    # TODO: scope will change as we know more
    @applications = CrimeApplication.joins(:people).includes(:applicant).merge(Applicant.with_name)
  end

  def edit; end
end
