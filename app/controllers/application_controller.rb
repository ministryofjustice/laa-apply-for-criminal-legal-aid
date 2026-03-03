class ApplicationController < ActionController::Base
  include Routing
  include ErrorHandling

  helper StepsHelper,
         AnalyticsHelper,
         AuthHelper

  prepend_before_action :authenticate_provider!

  add_flash_types :success

  around_action :switch_locale

  def current_crime_application
    return @current_crime_application if defined?(@current_crime_application)

    @current_crime_application = CrimeApplication.active.find_by(
      id: application_id,
      office_code: current_office_code
    )
  end
  helper_method :current_crime_application

  def current_office_code
    @current_office_code ||= current_provider&.selected_office_code
  end
  helper_method :current_office_code

  def current_office
    return nil unless current_office_code

    @current_office ||= Office.find(current_office_code)
  end
  helper_method :current_office

  def require_current_office!
    return if current_office&.active?

    redirect_to steps_provider_select_office_path
  end

  def switch_locale(&action)
    locale = params[:locale] || I18n.default_locale
    I18n.with_locale(locale, &action)
  end

  private

  def initialize_crime_application(attributes = {}, &block)
    attributes[:office_code] = current_office_code

    CrimeApplication.create(attributes).tap do |crime_application|
      yield(crime_application) if block
    end
  end

  def present_crime_application
    @crime_application = helpers.present(
      current_crime_application, CrimeApplicationPresenter
    )
  end

  def application_id
    params[:id]
  end

  def set_security_headers
    response.headers['Cache-Control'] = 'no-cache, no-store, must-revalidate'
    response.headers['Pragma'] = 'no-cache'
  end
end
