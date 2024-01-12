class CompletedApplicationsController < DashboardController
  include DatastoreApplicationConsumer

  before_action :check_crime_application_presence,
                :present_crime_application, only: [:show]

  def index
    @applications = Datastore::ListApplications.new(
      filtering: filtering_params, sorting: sorting_params, pagination: pagination_params
    ).call&.page(params[:page])
  end

  def show
    @presenter = Summary::HtmlPresenter.new(
      crime_application: current_crime_application
    )
  end

  def recreate
    Datastore::ApplicationRehydration.new(
      child_application, parent: current_crime_application
    ).call

    # Redirect to the check your answers (review) page
    # of the newly created application
    redirect_to edit_steps_submission_review_path(child_application)
  end

  def create_post_submission_evidence
    Datastore::PostSubmissionHydration.new(
      child_application, parent: current_crime_application
    ).call

    # Redirect to the check your answers (review) page
    # of the newly created application
    redirect_to edit_steps_post_submission_evidence_evidence_upload_path(
      child_application
    )
  end

  private

  def child_application
    usn = current_crime_application.reference

    # There can only be one application in progress with same USN
    CrimeApplication.find_by(usn:) || initialize_crime_application(usn:)
  end

  def sortable_columns
    %w[submitted_at]
  end

  def sorting_params
    {
      sort_by: helpers.sort_by,
      sort_direction: helpers.sort_direction
    }
  end

  def pagination_params
    {
      page: params[:page],
      per_page: Kaminari.config.default_per_page,
    }
  end

  def filtering_params
    {
      status: helpers.status_filter,
      office_code: current_office_code,
    }
  end
end
