class CompletedApplicationsController < DashboardController
  before_action :check_crime_application_presence,
                :present_crime_application, only: [:show]

  def index
    @applications = applications_from_datastore

    @in_progress_applications_count = CrimeApplication.in_progress
                                                      .joins(:people)
                                                      .includes(:applicant)
                                                      .merge(Applicant.with_name)
                                                      .count

    # TODO: counter not yet coming from datastore
    @returned_applications_count = CrimeApplication.returned.count
  end

  def show
    @presenter = Summary::HtmlPresenter.new(
      crime_application: current_crime_application
    )
  end

  def amend
    ApplicationAmendment.new(current_crime_application).call

    # Redirect to check your answers (review) page
    redirect_to edit_steps_submission_review_path(current_crime_application)
  end

  private

  # rubocop:disable Metrics/MethodLength
  def applications_from_datastore
    if FeatureFlags.datastore_submission.enabled?
      result = DatastoreApi::Requests::ListApplications.new(
        status: status_filter, **pagination_params
      ).call

      @paginator = InfinitePaginationV2.new(
        pagination: result.pagination,
        params: params,
      )

      result
    else
      # :nocov:
      CrimeApplication
        .where(status: status_filter)
        .joins(:people)
        .includes(:applicant)
        .merge(CrimeApplication.order(submitted_at: :desc))
      # :nocov:
    end
  end
  # rubocop:enable Metrics/MethodLength

  def status_filter
    allowed_statuses = [
      ApplicationStatus::SUBMITTED, ApplicationStatus::RETURNED
    ].map(&:to_s)

    allowed_statuses.include?(params[:q]) ? params[:q] : allowed_statuses.first
  end

  def pagination_params
    {
      limit: params[:limit],
      sort: params[:sort],
      page_token: params[:page_token],
    }
  end

  # FIXME: Once we have datastore working properly,
  # clean up code that talks to local database
  def current_crime_application
    return if params[:id].blank?

    @current_crime_application ||= if FeatureFlags.datastore_submission.enabled?
                                     DatastoreApi::Requests::GetApplication.new(
                                       application_id: params[:id]
                                     ).call
                                   else
                                     CrimeApplication.not_in_progress.find_by(id: params[:id])
                                   end
  end
end
