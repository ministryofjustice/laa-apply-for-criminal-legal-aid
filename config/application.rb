require_relative "boot"

require "rails"
require "active_record/railtie"
# require "active_storage/engine"
require "action_controller/railtie"
require "action_view/railtie"
require "action_mailer/railtie"
require "active_job/railtie"
# require "action_cable/engine"
# require "action_mailbox/engine"
# require "action_text/engine"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module LaaApplyForCriminalLegalAid
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.

    # Do not change unless you know what you are doing. All services
    # should be configured to UTC zone, and only in the views present
    # dates in the user’s time zone (in our case, `London`).
    config.time_zone = 'UTC'

    # config.eager_load_paths << Rails.root.join("extras")

    # Do not autoload all helpers in all controllers
    config.action_controller.include_all_helpers = false

    # This automatically adds id: :uuid to create_table in all future migrations
    config.generators do |g|
      g.orm :active_record, primary_key_type: :uuid
    end

    config.i18n.available_locales = %i[en cy]
    config.i18n.default_locale = :en

    # Prohibit all HTML tags
    config.action_view.sanitized_allowed_tags = []

    config.x.analytics.ga_tracking_id = ENV['GA_TRACKING_ID']
    config.x.analytics.cookies_consent_name = 'crime_apply_cookies_consent'.freeze
    config.x.analytics.cookies_consent_expiration = 6.months

    config.x.benefit_checker.use_mock = ENV.fetch('BC_USE_DEV_MOCK', 'false')
    config.x.benefit_checker.wsdl_url = ENV.fetch('BC_WSDL_URL', nil)
    config.x.benefit_checker.lsc_service_name = ENV.fetch('BC_LSC_SERVICE_NAME', nil)
    config.x.benefit_checker.client_org_id = ENV.fetch('BC_CLIENT_ORG_ID', nil)
    config.x.benefit_checker.client_user_id = ENV.fetch('BC_CLIENT_USER_ID', nil)

    config.x.auth_idp = ENV.fetch('AUTH_IDP', 'entra')

    # Time after which a user's session will expire if they
    # haven’t interacted with the service.
    config.x.session.timeout_in = ENV.fetch('SESSION_TIMEOUT_MINUTES', 60).to_i.minutes

    # Time after which a user will be required to sign in again,
    # regardless of their activity (session lifespan).
    config.x.session.reauthenticate_in = ENV.fetch('REAUTHENTICATE_AFTER_MINUTES', 1440).to_i.minutes

    config.x.gatekeeper= config_for(
      :gatekeeper, env: ENV.fetch('ENV_NAME', 'localhost')
    )

    config.x.inactive_offices = config_for(
      :inactive_offices, env: ENV.fetch('ENV_NAME', 'localhost')
    )
  end
end
