class ApplicationController < ActionController::Base
  include StepsHelper

  # :nocov:
  def current_crime_application
    @current_crime_application ||= CrimeApplication.find_by(id: session[:crime_application_id])
  end
  helper_method :current_crime_application
  # :nocov:

  private

  # :nocov:
  def initialize_crime_application(attributes = {})
    CrimeApplication.create(attributes).tap do |crime_application|
      session[:crime_application_id] = crime_application.id
    end
  end
  # :nocov:
end
