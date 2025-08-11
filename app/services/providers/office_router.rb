module Providers
  class OfficeRouter
    include Rails.application.routes.url_helpers
    include Routing

    attr_reader :provider

    def initialize(provider)
      @provider = provider
    end

    def self.call(provider)
      new(provider).path
    end

    def path
      if provider.selected_office_code.blank?
        edit_steps_provider_select_office_path
      elsif provider.multiple_offices?
        edit_steps_provider_confirm_office_path
      else
        crime_applications_path
      end
    end
  end
end
