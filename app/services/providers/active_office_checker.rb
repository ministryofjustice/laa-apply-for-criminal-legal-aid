module Providers
  class ActiveOfficeChecker
    attr_reader :auth_info

    def initialize(auth_info)
      @auth_info = auth_info
    end

    def active_office_codes
      if inactive_office_codes && auth_info.office_codes.size > 1
        calculate_active_office_codes
      else
        auth_info.office_codes
      end
    end

    private

    def calculate_active_office_codes
      auth_info.office_codes - inactive_office_codes
    end

    def inactive_office_codes
      Rails.configuration.x.inactive_offices.inactive_office_codes
    end
  end
end
