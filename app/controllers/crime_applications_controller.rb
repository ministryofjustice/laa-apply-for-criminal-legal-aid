class CrimeApplicationsController < ApplicationController
  def index
    # TODO: scope will change as we know more
    @applications = CrimeApplication.all
  end

  def edit; end
end
