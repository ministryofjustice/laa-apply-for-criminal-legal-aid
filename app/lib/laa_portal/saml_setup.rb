module LaaPortal
  class SamlSetup
    SP_ENTITY_ID = 'crime-apply'.freeze
    NAME_ID_FORMAT = 'urn:oasis:names:tc:SAML:1.1:nameid-format:unspecified'.freeze

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
        sp_entity_id: SP_ENTITY_ID,
        name_identifier_format: NAME_ID_FORMAT,
        certificate: ENV.fetch('LAA_PORTAL_SP_CERT', nil),
        private_key: ENV.fetch('LAA_PORTAL_SP_PRIVATE_KEY', nil),
        idp_sso_service_binding: :redirect,
        idp_slo_service_binding: :redirect,
        single_logout_service_url: sp_single_logout_url,
        security: {
          digest_method: XMLSecurity::Document::SHA256,
          signature_method: XMLSecurity::Document::RSA_SHA256,
          authn_requests_signed: true,
          logout_responses_signed: true,
          want_assertions_signed: true,
          want_assertions_encrypted: true,
          check_idp_cert_expiration: true,
          check_sp_cert_expiration: true,
        },
        request_attributes: {},
        attribute_statements: {
          email: ['USER_EMAIL'],
          roles: ['LAA_APP_ROLES'],
          office_codes: ['LAA_ACCOUNTS'],
        }
      )
    end
    # rubocop:enable Metrics/MethodLength

    private

    def sp_single_logout_url
      "#{@request.base_url}/providers/auth/saml/slo"
    end

    def metadata_url
      ENV.fetch('LAA_PORTAL_IDP_METADATA_URL', nil)
    end

    def metadata_file
      ENV.fetch('LAA_PORTAL_IDP_METADATA_FILE', nil)
    end

    def idp_metadata_parser
      OneLogin::RubySaml::IdpMetadataParser.new
    end

    def parse_metadata_and_merge(config = {})
      @env['omniauth.strategy'].options.merge!(
        metadata_config.merge(config)
      )
    end

    # rubocop:disable Metrics/MethodLength
    def metadata_config
      if metadata_url.present?
        metadata_from_server
      elsif metadata_file.present?
        metadata_from_file
      else
        raise 'Either metadata URL or metadata file must be configured'
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
    # rubocop:enable Metrics/MethodLength

    def metadata_from_server
      # An explicit timeout is set, as the gem parser does not have one,
      # which means it hangs for a very long time if URL is not reachable.
      Timeout.timeout(3) do
        idp_metadata_parser.parse_remote_to_hash(metadata_url)
      end
    end

    def metadata_from_file
      idp_metadata_parser.parse_to_hash(
        Rails.root.join(metadata_file).read
      )
    end
  end
end
