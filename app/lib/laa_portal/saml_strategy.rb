module LaaPortal
  class SamlStrategy < OmniAuth::Strategies::SAML
    # :nocov:
    def auth_hash
      self.class.auth_adapter.call(super)
    end
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
