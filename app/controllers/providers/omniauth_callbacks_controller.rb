module Providers
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    skip_before_action :verify_authenticity_token
    before_action :check_provider_is_enrolled, only: [:saml, :azure_ad]

    def saml
      provider = Provider.from_omniauth(auth_hash)

      sign_in_and_redirect(
        provider, event: :authentication
      )
    end

    # :nocov:
    def azure_ad
      saml
    end
    # :nocov:

    def failure
      # Let the application generic error handling deal with the
      # exception. Refer to `controllers/concerns/error_handling.rb`
      raise
    end

    private

    def after_sign_in_path_for(_)
      Providers::OfficeRouter.call(current_provider)
    end

    def auth_hash
      request.env['omniauth.auth']
    end

    def check_provider_is_enrolled
      gatekeeper = Providers::Gatekeeper.new(auth_hash.info)
      return if gatekeeper.provider_enrolled?

      Rails.logger.warn 'Not enrolled provider access attempt. ' \
                        "UID: #{auth_hash.uid}, accounts: #{auth_hash.info.office_codes}"

      redirect_to not_enrolled_errors_path
    end
  end
end
