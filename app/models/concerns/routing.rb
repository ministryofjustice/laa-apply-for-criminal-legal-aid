module Routing
  extend ActiveSupport::Concern

  included do
    include Rails.application.routes.url_helpers
  end

  # :nocov:
  def default_url_options
    {}
  end
  # :nocov:
end
