module ErrorHandling
  extend ActiveSupport::Concern

  included do
    rescue_from Exception do |exception|
      case exception
      when Errors::InvalidSession, ActionController::InvalidAuthenticityToken
        redirect_to invalid_session_errors_path
      when Errors::ApplicationNotFound
        redirect_to application_not_found_errors_path
      # NOTE: Add more custom errors as they are needed, for instance:
      # when Errors::ApplicationSubmitted
      #   redirect_to application_submitted_errors_path
      else
        raise if Rails.application.config.consider_all_requests_local

        Sentry.capture_exception(exception)
        redirect_to unhandled_errors_path
      end
    end
  end

  private

  def check_crime_application_presence
    raise Errors::InvalidSession unless current_crime_application
  end
end
