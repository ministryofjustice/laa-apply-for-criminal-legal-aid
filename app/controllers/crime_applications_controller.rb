class CrimeApplicationsController < DashboardController
  before_action :check_crime_application_presence,
                :present_crime_application, only: [:edit, :destroy, :confirm_destroy]

  def index
    @applications = in_progress_scope.merge(
      CrimeApplication.order(**sorting_params)
    ).page params[:page]
  end

  def edit
    if @crime_application.application_type == ApplicationType::POST_SUBMISSION_EVIDENCE.to_s
      redirect_to edit_steps_evidence_upload_path(@crime_application)
    end

    @tasklist = TaskList::Collection.new(
      view_context, crime_application: current_crime_application
    )
  end

  def create
    initialize_crime_application do |crime_application|
      redirect_to edit_steps_client_has_partner_path(crime_application)
    end
  end

  def destroy
    ApplicationPurger.call(current_crime_application, log_context)

    redirect_to crime_applications_path,
                flash: {
                  success: t('.success_flash', applicant_name: @crime_application.applicant_name)
                }
  end

  def confirm_destroy; end

  private

  def sortable_columns
    %w[created_at]
  end

  def sorting_params
    { helpers.sort_by => helpers.sort_direction }
  end

  def log_context
    LogContext.new(current_provider: current_provider, ip_address: request.remote_ip)
  end
end
