class ApplicationController < ActionController::Base
  include ErrorHandling
  include StepsHelper

  add_flash_types :success

  # NOTE: once we have applications linked to each provider, this
  # needs to be scoped to the currently signed in provider
  def current_crime_application
    @current_crime_application ||= CrimeApplication.in_progress.find_by(id: params[:id])
  end
  helper_method :current_crime_application

  private

  def initialize_crime_application(attributes = {}, &block)
    CrimeApplication.create(attributes).tap do |crime_application|
      yield(crime_application) if block
    end
  end
end
