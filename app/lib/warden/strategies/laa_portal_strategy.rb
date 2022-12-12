module Warden
  module Strategies
    class LaaPortalStrategy < ::Warden::Strategies::Base
      def authenticate!
        if auth_env
          success!(user_details)
        else
          fail!
        end
      end

      private

      def auth_env
        request.env['omniauth.auth']
      end

      def user_details
        attrs = auth_env.info

        # These are `nil` when using samlmock.dev, so filling with something
        attrs.name  ||= auth_env.uid
        attrs.email ||= auth_env.uid

        # We get a comma-separated string, but want an array
        attrs.roles = attrs.roles.split(',')
        attrs.office_codes = attrs.office_codes.split(',')

        attrs
      end
    end
  end

  class UnauthorizedController < ActionController::Metal
    include ActionController::Redirecting
    include Rails.application.routes.url_helpers

    def self.call(env)
      @respond ||= action(:respond)
      @respond.call(env)
    end

    def respond
      redirect_to unauthorized_errors_path
    end
  end
end
