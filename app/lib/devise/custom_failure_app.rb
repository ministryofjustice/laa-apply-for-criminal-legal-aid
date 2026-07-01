module Devise
  class CustomFailureApp < Devise::FailureApp
    MAX_STORED_LOCATION_BYTES = 2048

    # rubocop:disable Metrics/MethodLength
    def redirect
      store_location_if_safe!

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

    private

    def store_location_if_safe!
      path = attempted_path.to_s
      if path.bytesize > MAX_STORED_LOCATION_BYTES
        Rails.logger.warn(
          "Skipping store_location! for oversized attempted path (#{path.bytesize} bytes)"
        )
        return
      end

      store_location!
    end
  end
end
