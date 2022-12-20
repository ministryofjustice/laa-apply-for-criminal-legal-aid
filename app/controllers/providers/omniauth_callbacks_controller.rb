module Providers
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    skip_before_action :verify_authenticity_token

    def saml
      provider = Provider.from_omniauth(auth_hash)

      sign_in_and_redirect(
        provider, event: :authentication
      )
    end

    private

    def after_sign_in_path_for(_)
      if current_provider.multiple_offices?
        edit_steps_provider_confirm_office_path
      else
        crime_applications_path
      end
    end

    def after_omniauth_failure_path_for(_)
      new_provider_session_path
    end

    def auth_hash
      request.env['omniauth.auth']
    end
  end
end
