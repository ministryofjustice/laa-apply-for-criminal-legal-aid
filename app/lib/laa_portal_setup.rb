class LaaPortalSetup
  class AuthSetupError < StandardError; end

  def initialize(env)
    @env = env
    @request = ActionDispatch::Request.new(env)
  end

  def self.call(env)
    return if OmniAuth.config.test_mode

    new(env).setup
  end

  # rubocop:disable Metrics/MethodLength
  def setup
    parse_metadata_and_merge(
      sp_entity_id: 'crime-apply',
      security: {
        authn_requests_signed: true,
        want_assertions_signed: true,
      },
      request_attributes: {},
      attribute_statements: {
        email: ['USER_EMAIL'],
        roles: ['LAA_APP_ROLES'],
        office_codes: ['LAA_ACCOUNTS'],
      }
    )
  rescue StandardError => e
    raise AuthSetupError, e
  end

  # :nocov:
  def self.mock_auth
    OmniAuth::AuthHash.new(
      provider: 'saml',
      uid: 'test-uid',
      info: {
        name: 'test-user',
        email: 'test@example.com',
      },
      extra: {
        raw_info: {
          USER_EMAIL: 'test@example.com',
          LAA_APP_ROLES: ['CCR_CCRGradeA1'],
          LAA_ACCOUNTS: ['1A123B'],
        }
      }
    )
  end
  # :nocov:
  # rubocop:enable Metrics/MethodLength

  private

  def parse_metadata_and_merge(config = {})
    @env['omniauth.strategy'].options.merge!(
      metadata_config.merge(config)
    )
  end

  # An explicit timeout is set, as the gem parser does not have one,
  # which means it hangs for a very long time if URL is not reachable.
  def metadata_config
    Timeout.timeout(3) do
      OneLogin::RubySaml::IdpMetadataParser.new.parse_remote_to_hash(metadata_url)
    end
  rescue StandardError => e
    if e.is_a?(Timeout::Error)
      e = StandardError.new(
        "Execution expired parsing remote metadata: `#{metadata_url}`"
      )
    end

    Rails.logger.error(e)
    Sentry.capture_exception(e)

    raise(e) # re-raise exception
  end

  def metadata_url
    ENV.fetch('LAA_PORTAL_IDP_METADATA_URL')
  end

  # This is a middleware class used to catch exceptions
  # during the strategy `setup` phase, like metadata timeouts.
  # :nocov:
  class AuthSetupErrorCatcher
    def initialize(app)
      @app = app
    end

    def call(env)
      @app.call(env)
    rescue LaaPortalSetup::AuthSetupError => e
      flash = ActionDispatch::Flash::FlashHash.new(notice: e.message)

      Rack::Request.new(env).session['flash'] = flash.to_session_value

      [302, { 'Location' => '/' }, []]
    end
  end
  # :nocov:
end
