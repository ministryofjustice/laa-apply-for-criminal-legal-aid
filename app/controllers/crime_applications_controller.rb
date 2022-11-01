class CrimeApplicationsController < DashboardController
  before_action :check_crime_application_presence,
                :present_crime_application, only: [:show, :edit, :destroy, :confirm_destroy]

  def index
    # TODO: scope will change as we know more
    @applications = CrimeApplication
                    .in_progress
                    .joins(:people)
                    .includes(:applicant)
                    .merge(Applicant.with_name)
                    .merge(CrimeApplication.order(created_at: :desc))

    @submitted_applications_count = CrimeApplication.submitted.count
    @returned_applications_count = CrimeApplication.returned.count
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
