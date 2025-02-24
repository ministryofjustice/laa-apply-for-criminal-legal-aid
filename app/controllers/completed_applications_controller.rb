class CompletedApplicationsController < DashboardController
  include DatastoreApplicationConsumer

  before_action :check_crime_application_presence,
                :present_crime_application, only: [:show]

  layout 'application_dashboard', only: [:index]

  def index
    redirect_to submitted_applications_path
  end

  def show
    @presenter = Summary::HtmlPresenter.new(
      crime_application: current_crime_application
    )
  end

  def recreate
    usn = current_crime_application.reference
    application_type = current_crime_application['application_type']

    # There can only be one application in progress with same USN across all offices
    crime_application = CrimeApplication.find_by(usn:) || initialize_crime_application(usn:, application_type:)

    # Ensure that the 'in progress' application is associated with the correct office code.
    # If this exception is raised, there may be an issue with the data integrity.
    raise 'In progress in another office.' unless crime_application.office_code == current_office_code

    Datastore::ApplicationRehydration.new(
      crime_application, parent: current_crime_application
    ).call

    # Redirect to the check your answers (review) page
    # of the newly created application
    redirect_to edit_steps_submission_review_path(crime_application)
  end

  def create_pse
    pse_application = Pse::FindOrCreate.new(
      initial_application: Adapters::JsonApplication.new(current_crime_application)
    ).call

    redirect_to edit_steps_evidence_upload_path(pse_application)
  end
end
