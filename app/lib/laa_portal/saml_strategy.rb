module LaaPortal
  class SamlStrategy < OmniAuth::Strategies::SAML
    # :nocov:
    def auth_hash
      self.class.auth_adapter.call(super)
    end

    # Reason for overriding this method is the gem `omniauth-saml`
    # is raising an `Exception` class, instead of an `StandardError`,
    # and Omniauth is not catching it because of that, blowing up
    # at the Rack level, without showing a "nice" error page.
    # Re-raise as `StandardError` and also report to Sentry.
    # rubocop:disable Lint/RescueException
    def other_phase
      super
    rescue Exception => e
      Sentry.capture_exception(e)
      raise StandardError, e
    end
    # rubocop:enable Lint/RescueException
    # :nocov:

    class << self
      def mock_auth
        auth_adapter.call(
          OmniAuth::AuthHash.new(
            provider: 'saml',
            uid: 'test-user',
            info: {
              email: 'provider@example.com',
              roles: 'EFORMS,EFORMS_eFormsAuthor,CRIMEAPPLY',
              office_codes: '1A123B:2A555X',
            }
          )
        )
      end

      def auth_adapter
        Providers::AuthAdapter
      end
    end
  end
end
