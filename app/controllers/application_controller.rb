class ApplicationController < ActionController::Base
  include StepsHelper

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
