module Routing
  extend ActiveSupport::Concern

  included do
    include Rails.application.routes.url_helpers
  end

  # :nocov:
  def default_url_options
    I18n.locale == I18n.default_locale ? {} : { locale: I18n.locale }
  end
  # :nocov:
end
