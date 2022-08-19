class ApplicationController < ActionController::Base
  include ErrorHandling
  include StepsHelper

  add_flash_types :success

  def current_crime_application
    @current_crime_application ||= CrimeApplication.find_by(id: session[:crime_application_id])
  end
  helper_method :current_crime_application

  private

  def initialize_crime_application(attributes = {})
    CrimeApplication.create(attributes).tap do |crime_application|
      session[:crime_application_id] = crime_application.id
    end
  end
end
