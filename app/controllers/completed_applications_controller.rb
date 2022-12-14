class CompletedApplicationsController < DashboardController
  before_action :check_crime_application_presence,
                :present_crime_application, only: [:show]

  def index
    @applications = applications_from_datastore
  end

  def show
    @presenter = Summary::HtmlPresenter.new(
      crime_application: current_crime_application
    )
  end

  # TODO: implement re-hydration with datastore, as this
  # action was relying on existing local DB records.
  # :nocov:
  def amend
    ApplicationAmendment.new(current_crime_application).call

    # Redirect to check your answers (review) page
    redirect_to edit_steps_submission_review_path(current_crime_application)
  end
  # :nocov:

  private

  def applications_from_datastore
    result = DatastoreApi::Requests::ListApplications.new(
      status: status_filter, **pagination_params
    ).call

    Kaminari.paginate_array(result, total_count: result.pagination['total_count']).page(params[:page])
  end

  def status_filter
    allowed_statuses = [
      ApplicationStatus::SUBMITTED, ApplicationStatus::RETURNED
    ].map(&:to_s)

    allowed_statuses.include?(params[:q]) ? params[:q] : allowed_statuses.first
  end

  def pagination_params
    {
      sort: params[:sort],
      page: params[:page],
      per_page: Kaminari.config.default_per_page,
    }
  end

  def current_crime_application
    return if params[:id].blank?

    @current_crime_application ||= DatastoreApi::Requests::GetApplication.new(
      application_id: params[:id]
    ).call
  end
end
