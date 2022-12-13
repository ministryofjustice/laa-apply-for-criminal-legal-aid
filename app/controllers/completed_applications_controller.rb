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
    @returned_applications_count = returned_applications_count
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

    if DatastoreApi.configuration.api_path.include?('v1')
      @paginator = InfinitePaginationV2.new(
        pagination: result.pagination,
        params: params,
      )
    end

    @pagination = result.pagination if DatastoreApi.configuration.api_path.include?('v2')

    result
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
    }.merge(api_params)
  end

  def api_params
    if DatastoreApi.configuration.api_path.include?('v2')
      return { page: params[:page],
per_page: Kaminari.config.default_per_page }
    end

    { limit: params[:limit], page_token: params[:page_token] }
  end

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

  def current_crime_application
    return if params[:id].blank?

    @current_crime_application ||= DatastoreApi::Requests::GetApplication.new(
      application_id: params[:id]
    ).call
  end
end
