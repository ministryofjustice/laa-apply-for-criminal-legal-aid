module Providers
  class OfficeRouter
    include Rails.application.routes.url_helpers

    attr_reader :provider

    def initialize(provider, locale)
      @locale = locale
      @provider = provider
    end

    def self.call(provider, locale)
      new(provider, locale).path
    end

    def path
      if provider.selected_office_code.blank?
        edit_steps_provider_select_office_path(locale: @locale)
      elsif provider.multiple_offices?
        edit_steps_provider_confirm_office_path(locale: @locale)
      else
        crime_applications_path(locale: @locale)
      end
    end
  end
end
