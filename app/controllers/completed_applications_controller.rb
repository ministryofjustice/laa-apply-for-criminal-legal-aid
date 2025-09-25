class CompletedApplicationsController < DashboardController
  include DatastoreApplicationConsumer

  before_action :check_crime_application_presence,
                :present_crime_application, only: [:show]
  before_action :block_contingent_liability!, except: [:index, :show]

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
    crime_application = initialize_crime_application(usn:, application_type:)

    Datastore::ApplicationRehydration.new(
      crime_application, parent: current_crime_application
    ).call

    redirect_to edit_steps_submission_review_path(crime_application)
  rescue ActiveRecord::RecordNotUnique
    redirect_to edit_crime_application_path CrimeApplication.find_by!(usn:)
  end

  def create_pse
    pse_application = Pse::FindOrCreate.new(
      initial_application: Adapters::JsonApplication.new(current_crime_application)
    ).call

    redirect_to edit_steps_evidence_upload_path(pse_application)
  end

  private

  def usn
    current_crime_application.reference
  end

  def application_type
    current_crime_application['application_type']
  end
end
