class LaaPortalSetup
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
      certificate: ENV.fetch('LAA_PORTAL_SP_CERT', nil),
      private_key: ENV.fetch('LAA_PORTAL_SP_PRIVATE_KEY', nil),
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
  end

  # :nocov:
  def self.mock_auth
    OmniAuth::AuthHash.new(
      provider: 'saml',
      uid: 'test-uid',
      info: {
        name: 'test-user',
        email: 'test@example.com',
        roles: 'CCR_CCRGradeA1,CCLF_BillManager',
        office_codes: '1A123B,2A555X',
      }
    )
  end
  # :nocov:
  # rubocop:enable Metrics/MethodLength

  private

  def metadata_url
    ENV.fetch('LAA_PORTAL_IDP_METADATA_URL', nil)
  end

  def parse_metadata_and_merge(config = {})
    @env['omniauth.strategy'].options.merge!(
      metadata_config.merge(config)
    )
  end

  def metadata_config
    return manual_override_config if metadata_url.blank?

    # An explicit timeout is set, as the gem parser does not have one,
    # which means it hangs for a very long time if URL is not reachable.
    Timeout.timeout(3) do
      OneLogin::RubySaml::IdpMetadataParser.new.parse_remote_to_hash(metadata_url)
    end
  rescue StandardError => e
    if e.is_a?(Timeout::Error)
      e = StandardError.new(
        "Execution expired parsing remote metadata: `#{metadata_url}`"
      )
    end

    Sentry.capture_exception(e)
    raise(e) # re-raise exception
  end

  def manual_override_config
    {
      idp_cert: ENV.fetch('LAA_PORTAL_IDP_CERT'),
      idp_sso_service_url: ENV.fetch('LAA_PORTAL_IDP_SSO_URL'),
      idp_sso_service_binding: :redirect,
      assertion_consumer_service_binding: :post,
    }
  end
end
