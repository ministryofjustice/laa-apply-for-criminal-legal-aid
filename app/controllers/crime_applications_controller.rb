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

  def destroy
    @application = CrimeApplication.find(delete_params[:id])
    @full_name = @application.applicant.full_name

    if request.get?
      render :delete
    else
      @application.destroy
      flash[:alert] = "#{@full_name}'s application has been permenantly deleted"
      redirect_to crime_applications_path
    end
  end

  private

  # NOTE: once we have applications linked to each provider, this
  # needs to be scoped to the currently signed in provider
  def crime_application
    CrimeApplication.find(params.require(:id))
  end

  def delete_params
    params.permit(:id)
  end
end
