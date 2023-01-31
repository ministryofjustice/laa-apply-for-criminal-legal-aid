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
