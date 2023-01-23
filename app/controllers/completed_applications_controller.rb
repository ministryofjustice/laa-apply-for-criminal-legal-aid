class CompletedApplicationsController < DashboardController
  before_action :check_crime_application_presence,
                :present_crime_application, only: [:show]

  def index
    @applications = Datastore::GetApplications.new(
      status: status_filter, office_code: current_office_code, **pagination_params
    ).call&.page(params[:page])
  end

  def show
    @presenter = Summary::HtmlPresenter.new(
      crime_application: current_crime_application
    )
  end

  # TODO: this is WIP, can be tested by manually setting
  # an application in the `returned` status.
  # :nocov:
  def recreate
    usn = current_crime_application.reference

    # There can only be one application in progress with same USN
    crime_application = CrimeApplication.find_by(usn:) || initialize_crime_application(usn:)

    Datastore::ApplicationRehydration.new(
      crime_application, parent: current_crime_application
    ).call

    # Redirect to the check your answers (review) page
    # of the newly created application
    redirect_to edit_steps_submission_review_path(crime_application)
  end
  # :nocov:

  private

  def pagination_params
    {
      sort: sort_direction,
      page: params[:page],
      per_page: Kaminari.config.default_per_page,
    }
  end

  def sort_direction
    return nil if params[:sort].blank?

    "#{params[:sort]}ending"
  end

  def status_filter
    allowed_statuses = [
      ApplicationStatus::SUBMITTED, ApplicationStatus::RETURNED
    ].map(&:to_s)

    allowed_statuses.include?(params[:q]) ? params[:q] : allowed_statuses.first
  end

  def current_crime_application
    return if params[:id].blank?

    @current_crime_application ||= DatastoreApi::Requests::GetApplication.new(
      application_id: params[:id]
    ).call
  end
end
