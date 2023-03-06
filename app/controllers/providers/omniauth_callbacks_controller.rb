module Providers
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    skip_before_action :verify_authenticity_token
    before_action :check_provider_is_allowed, only: [:saml]

    def saml
      provider = Provider.from_omniauth(auth_hash)

      sign_in_and_redirect(
        provider, event: :authentication
      )
    end

    private

    def after_sign_in_path_for(_)
      Providers::OfficeRouter.call(current_provider)
    end

    def after_omniauth_failure_path_for(_)
      new_provider_session_path
    end

    def auth_hash
      request.env['omniauth.auth']
    end

    def check_provider_is_allowed
      gatekeeper = Providers::Gatekeeper.new(auth_hash.info)

      return if gatekeeper.access_allowed?

      set_flash_message(
        :alert, gatekeeper.reason,
        scope: [:devise, :omniauth_callbacks, :provider_gatekeeper],
      )

      redirect_to root_path
    end
  end
end
