class CrimeApplicationsController < DashboardController
  before_action :check_crime_application_presence,
                :present_crime_application, only: [:edit, :destroy, :confirm_destroy]

  def index
    @applications = in_progress_scope.merge(
      CrimeApplication.order(**sorting_params)
    ).page params[:page]
  end

  def new
    @form_object = Start::FinancialCircumstancesChangedForm.build(
      CrimeApplication.new(office_code: current_office_code)
    )
  end

  def edit
    @tasklist = TaskList::Collection.new(
      view_context, crime_application: current_crime_application
    )
  end

  def create
    attrs = {}
    attrs[:application_type] = ApplicationType::CHANGE_IN_FINANCIAL_CIRCUMSTANCES if financial_circumstances_changed

    initialize_crime_application(attrs) do |crime_application|
      if FeatureFlags.cifc_journey.enabled? && financial_circumstances_changed
        redirect_to edit_steps_circumstances_appeal_reference_number_path(crime_application)
      elsif FeatureFlags.non_means_tested.enabled?
        redirect_to edit_steps_client_is_means_tested_path(crime_application)
      else
        redirect_to edit_crime_application_path(crime_application)
      end
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

  def new_application_params
    params
      .fetch(:start_financial_circumstances_changed_form)
      .permit(:has_financial_circumstances_changed)
  end

  def log_context
    LogContext.new(current_provider: current_provider, ip_address: request.remote_ip)
  end

  def financial_circumstances_changed
    @financial_circumstances_changed ||= (new_application_params[:has_financial_circumstances_changed] == 'yes')
  end
end
