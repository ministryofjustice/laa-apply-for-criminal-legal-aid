module Providers
  class OfficeRouter
    include Rails.application.routes.url_helpers

    attr_reader :provider

    def initialize(provider)
      @provider = provider
    end

    def self.call(provider)
      new(provider).path
    end

    def default_url_options
      I18n.locale == I18n.default_locale ? {} : { locale: I18n.locale }
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
