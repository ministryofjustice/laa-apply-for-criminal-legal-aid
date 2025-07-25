class ApplicationController < ActionController::Base
  include ErrorHandling

  helper StepsHelper,
         AnalyticsHelper,
         AuthHelper

  prepend_before_action :authenticate_provider!

  add_flash_types :success

  around_action :switch_locale

  def current_crime_application
    @current_crime_application ||= CrimeApplication.find_by(
      id: application_id,
      office_code: current_office_code
    )
  end
  helper_method :current_crime_application

  def current_office_code
    @current_office_code ||= current_provider&.selected_office_code
  end
  helper_method :current_office_code

  def switch_locale(&action)
    locale = params[:locale] || I18n.default_locale
    I18n.with_locale(locale, &action)
  end

  def default_url_options
    I18n.locale == I18n.default_locale ? {} : { locale: I18n.locale }
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
