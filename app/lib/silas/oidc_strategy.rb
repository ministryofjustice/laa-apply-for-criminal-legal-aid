module Silas
  class OidcStrategy < OmniAuth::Strategies::OpenIDConnect
    info { { email:, roles:, office_codes: } }

    private

    # If the Provider Data API feature is enabled, laa_accounts are filtered
    # to include only active crime office_codes.
    def office_codes
      ProviderDataApi::ActiveOfficeCodesFilter.call(
        laa_accounts,
        area_of_law: 'CRIME LOWER',
        translator: Providers::SchedulesToOfficeTranslator
      )
    end

    # The `LAA_ACCOUNTS` custom claim can be either a single office code (as a string)
    # or multiple office codes (as an array). Here we normalise the value to always
    # return an array.
    def laa_accounts
      [*user_info.raw_attributes.fetch('LAA_ACCOUNTS')]
    end

    def email
      user_info.email
    end

    # Access to Crime Apply will be managed by SILAS and EntraID.
    # Setting roles as `ACCESS_CRIME_APPLY` here until that is confirmed.
    # Once confirmed, `role` can be removed from providers altogether.
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
