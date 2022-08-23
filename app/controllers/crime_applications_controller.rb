class CrimeApplicationsController < ApplicationController
  before_action :check_crime_application_presence, except: [:index, :create]
  before_action :set_applicant_name, only: [:destroy, :confirm_destroy]

  def index
    # TODO: scope will change as we know more
    @applications = CrimeApplication
                    .viewable
                    .joins(:people)
                    .includes(:applicant)
                    .merge(Applicant.with_name)
  end

  def create
    initialize_crime_application do |crime_application|
      redirect_to edit_steps_client_has_partner_path(crime_application)
    end
  end

  def edit
    @tasklist = TaskList::Collection.new(
      view_context, crime_application: current_crime_application
    )
  end

  def destroy
    current_crime_application.destroy
    redirect_to crime_applications_path,
                flash: {
                  success: t('.success_flash', applicant_name: @applicant_name)
                }
  end

  def confirm_destroy; end

  private

  def set_applicant_name
    @applicant_name = current_crime_application.applicant.full_name
  end
end
