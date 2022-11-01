class CompletedApplicationsController < DashboardController
  before_action :check_crime_application_presence,
                :present_crime_application, only: [:show]

  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  # TODO: Applications will change when we have the document store
  # working so then we can use a nicer query that won't require
  # disabling one of the cops.
  def index
    @applications = if params[:q] == 'returned'
                      CrimeApplication
                        .returned
                        .joins(:people)
                        .includes(:applicant)
                        .merge(CrimeApplication.order(created_at: :desc))
                    else
                      CrimeApplication
                        .submitted
                        .joins(:people)
                        .includes(:applicant)
                        .merge(CrimeApplication.order(created_at: :desc))
                    end

    @in_progress_applications_count = CrimeApplication.in_progress
                                                      .joins(:people)
                                                      .includes(:applicant)
                                                      .merge(Applicant.with_name)
                                                      .count
    @submitted_applications_count = CrimeApplication.submitted.count
    @returned_applications_count = CrimeApplication.returned.count
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

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

  # TODO: this will go to the document store when we have it.
  # For now we fake it, and get it from the local DB as we are
  # not purging applications on submission yet.
  #
  def current_crime_application
    @current_crime_application ||= CrimeApplication.not_in_progress.find_by(id: params[:id])
  end
end
