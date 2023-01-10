class CrimeApplicationsController < DashboardController
  before_action :check_crime_application_presence,
                :present_crime_application, only: [:edit, :destroy, :confirm_destroy]

  def index
    @applications = in_progress_scope.merge(
      CrimeApplication.joins(:applicant)
    ).order(**sorting_params).page params[:page]
  end

  def edit
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
    current_crime_application.destroy
    redirect_to crime_applications_path,
                flash: {
                  success: t('.success_flash', applicant_name: @crime_application.applicant_name)
                }
  end

  def confirm_destroy; end

  private

  def order_param
    return 'created_at' unless ordering_param_allowed?

    return 'people.last_name' if params[:order] == 'applicant_name'

    params[:order]
  end

  def ordering_param_allowed?
    %w[created_at applicant_name].include? params[:order]
  end

  def sort_param
    params[:sort]&.to_sym || :desc
  end

  def sorting_params
    { order_param => sort_param }
  end
end
