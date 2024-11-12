class CrimeApplicationsController < DashboardController
  before_action :check_crime_application_presence,
                :present_crime_application, only: [:edit, :destroy, :confirm_destroy]

  layout 'application_dashboard', only: [:index]

  def index
    @applications = in_progress_scope.merge(
      CrimeApplication.order(**sorting_params)
    ).page params[:page]
  end

  def new
    @form_object = Start::IsCifcForm.new
  end

  def edit
    @tasklist = TaskList::Collection.new(
      view_context, crime_application: current_crime_application
    )
  end

  def create # rubocop:disable Metrics/MethodLength
    attrs = {}

    # Validation for forms usually performed in step controller but the
    # IsCifcForm is not part of the /step journey

    @form_object = Start::IsCifcForm.build(
      CrimeApplication.new(office_code: current_office_code),
      new_application_params[:is_cifc]
    )

    return render(:new, flash:) unless @form_object.valid?

    attrs[:application_type] = ApplicationType::CHANGE_IN_FINANCIAL_CIRCUMSTANCES if cifc?

    initialize_crime_application(attrs) do |crime_application|
      if cifc?
        redirect_to edit_steps_circumstances_pre_cifc_reference_number_path(crime_application)
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
    params.fetch(:start_is_cifc_form, {}).permit(:is_cifc)
  end

  def log_context
    LogContext.new(current_provider: current_provider, ip_address: request.remote_ip)
  end

  def cifc?
    @cifc ||= (new_application_params[:is_cifc] == 'yes')
  end
end
