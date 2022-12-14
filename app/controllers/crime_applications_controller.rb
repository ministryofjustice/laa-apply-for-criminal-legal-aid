class CrimeApplicationsController < DashboardController
  before_action :check_crime_application_presence,
                :present_crime_application, only: [:edit, :destroy, :confirm_destroy]

  def index
    @applications = in_progress_scope.merge(
      CrimeApplication.order(created_at: :desc)
    ).page params[:page]
  end

  def create
    initialize_crime_application do |crime_application|
      redirect_to edit_steps_client_has_partner_path(crime_application)
    end
  end

  def edit
    @tasklist = TaskList::Collection.new(
      view_context, crime_application: current_crime_application
    )
  end

  def destroy
    current_crime_application.destroy
    redirect_to crime_applications_path,
                flash: {
                  success: t('.success_flash', applicant_name: @crime_application.applicant_name)
                }
  end

  def confirm_destroy; end
end
