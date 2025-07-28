module Lassie
  class OidcStrategy < OmniAuth::Strategies::OpenIDConnect
    info { { email:, roles:, office_codes: } }
    private

    # The `LAA_ACCOUNTS` custom claim can be either a single office code (as a string)
    # or multiple office codes (as an array). Here we normalizes the value to always
    # return an array.
    def office_codes
      [*user_info.raw_attributes.fetch('LAA_ACCOUNTS')]
    end

    def email
      user_info.email
    end

    # Access to Crime Apply will be managed by LASSIE and EntraID.
    # Setting roles as `ACCESS_CRIME_APPLY` here until that is confirmed.
    # Once confirmed, `role` can be removed from providers althogether.
    def roles
      ['ACCESS_CRIME_APPLY']
    end

    class << self
      def mock_auth
        OmniAuth::AuthHash.new(
          provider: 'entra',
          uid: 'test-user',
          info: {
            email: 'provider@example.com',
            roles: ['ACCESS_CRIME_APPLY'],
            office_codes: %w[1A123B 2A555X 3B345C 4C567D]
          }
        )
      end
    end
  end
end
