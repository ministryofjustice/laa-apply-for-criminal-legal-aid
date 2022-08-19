class CrimeApplicationsController < ApplicationController
  before_action :crime_application_for_delete, only: [:destroy, :confirm_destroy]

  def index
    # TODO: scope will change as we know more
    @applications = CrimeApplication
                    .joins(:people)
                    .includes(:applicant)
                    .merge(Applicant.with_name)
  end

  def edit
    @tasklist = TaskList::Collection.new(
      view_context, crime_application: crime_application
    )
  end

  def destroy
    @application.destroy
    redirect_to crime_applications_path,
                flash: {
                  success: t('.success_flash', full_name: @full_name)
                }
  end

  def confirm_destroy
    render :confirm_destroy
  end

  private

  # NOTE: once we have applications linked to each provider, this
  # needs to be scoped to the currently signed in provider
  def crime_application
    CrimeApplication.find(params.require(:id))
  end

  def crime_application_for_delete
    @application = CrimeApplication.find(delete_params[:id])
    @full_name = @application.applicant.full_name
  end

  def delete_params
    params.permit(:id)
  end
end
