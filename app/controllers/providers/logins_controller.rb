# :nocov:
module Providers
  class LoginsController < Devise::SessionsController
    protected

    # def sign_in(_resource_name, provider)
    #   super
    # end

    # Devise will try to return to a previously login-protected page if available,
    # otherwise this is the fallback route to redirect the user after login
    def signed_in_root_path(_)
      crime_applications_path
    end

    def after_sign_out_path_for(_)
      root_path
    end
  end
end
# :nocov:
