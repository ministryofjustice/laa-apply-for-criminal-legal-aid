module Providers
  class Gatekeeper
    attr_reader :auth_info

    def initialize(auth_info)
      @auth_info = auth_info
    end

    def provider_enrolled?
      email_enrolled? || office_enrolled?
    end

    def office_enrolled?
      Gatekeeper.allowed_office_codes.intersect?(auth_info.office_codes)
    end

    # TODO: implement separately once decided if this is required
    def email_enrolled?
      false
    end

    class << self
      def active_office_codes
        allowed_office_codes - inactive_office_codes
      end

      def allowed_office_codes
        Rails.configuration.x.gatekeeper.office_codes || []
      end

      def inactive_office_codes
        Rails.configuration.x.inactive_offices.inactive_office_codes || []
      end
    end
  end
end
