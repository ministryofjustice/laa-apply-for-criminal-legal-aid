class ApplicationController < ActionController::Base
  include ErrorHandling
  include StepsHelper

  prepend_before_action :authenticate_provider!

  add_flash_types :success

  def current_crime_application
    @current_crime_application ||= CrimeApplication.find_by(id: params[:id])
  end
  helper_method :current_crime_application

  def current_office_code
    @current_office_code ||= current_provider&.selected_office_code
  end
  helper_method :current_office_code

  private

  def initialize_crime_application(attributes = {}, &block)
    attributes[:office_code] = current_office_code

    CrimeApplication.create(attributes).tap do |crime_application|
      yield(crime_application) if block
    end
  end
end
