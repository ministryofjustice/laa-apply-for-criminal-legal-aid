module Devise
  class CustomFailureApp < Devise::FailureApp
    # rubocop:disable Metrics/MethodLength
    def redirect
      store_location!

      message = warden_message || :unauthenticated

      Rails.logger.debug { "==> CustomFailureApp for message `#{message}`" }

      case message
      when :unauthenticated
        redirect_to unauthenticated_errors_path
      when :reauthenticate
        redirect_to reauthenticate_errors_path
      when :timeout
        redirect_to invalid_session_errors_path
      when :locked
        redirect_to account_locked_errors_path
      else
        # :nocov:
        super
        # :nocov:
      end
    end
    # rubocop:enable Metrics/MethodLength
  end
end
