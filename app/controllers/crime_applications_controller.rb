class CrimeApplicationsController < DashboardController
  before_action :check_crime_application_presence,
                :present_crime_application, only: [:edit, :destroy, :confirm_destroy]

  def index
    # TODO: scope will change as we know more
    applications = CrimeApplication
                   .in_progress
                   .joins(:people)
                   .includes(:applicant)
                   .merge(Applicant.with_name)
                   .merge(CrimeApplication.order(created_at: :desc))

    @applications = applications.page params[:page]

    @applications_count = applications.count
    @returned_applications_count = returned_applications_count
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

  private

  # rubocop:disable Metrics/AbcSize
  def returned_applications_count
    returned_params = { status: 'returned' }
    returned_params[:limit] = 1 if DatastoreApi.configuration.api_path.include?('v1')
    returned_params[:per_page] = 1 if DatastoreApi.configuration.api_path.include?('v2')

    result = DatastoreApi::Requests::ListApplications.new(**returned_params).call

    return result.pagination['total_count'] if DatastoreApi.configuration.api_path.include?('v2')

    result.pagination['total']
  end
  # rubocop:enable Metrics/AbcSize
end
