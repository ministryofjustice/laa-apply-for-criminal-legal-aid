require 'rails_helper'

describe LaaPortal::SamlSetup do
  subject { described_class.call(env) }

  let(:env) do
    {
      'omniauth.strategy' => double(options: {}),
      'rack.url_scheme' => 'http',
      'HTTP_HOST' => 'example.com',
    }
  end

  let(:metadata_url) { nil }
  let(:metadata_file) { nil }

  before do
    allow(Sentry).to receive(:capture_exception)
    allow(OmniAuth.config).to receive(:test_mode).and_return(false)

    stub_const(
      'ENV',
      ENV.to_h.merge(
        'LAA_PORTAL_IDP_METADATA_URL' => metadata_url,
        'LAA_PORTAL_IDP_METADATA_FILE' => metadata_file,
        'LAA_PORTAL_SP_CERT' => nil,
        'LAA_PORTAL_SP_PRIVATE_KEY' => nil,
      )
    )
  end

  describe '.setup' do
    context 'when no metadata endpoint and no local file are declared' do
      it 'raises an exception' do
        expect { subject }.to raise_exception(
          RuntimeError, /Either metadata URL or metadata file must be configured/
        )

        expect(Sentry).to have_received(:capture_exception).with(
          an_instance_of(RuntimeError)
        )
      end
    end

    context 'when a local metadata file is declared' do
      let(:metadata_file) { 'path/to/metadata.xml' }
      let(:metadata_result) { { foo: 'bar' } }

      before do
        allow_any_instance_of(
          OneLogin::RubySaml::IdpMetadataParser
        ).to receive(:parse_to_hash).with('dummy_config').and_return(metadata_result)
      end

      it 'uses a locally stored metadata file' do
        expect(
          Rails.root
        ).to receive(:join).with(metadata_file).and_return(double(read: 'dummy_config'))

        expect(
          subject
        ).to match(
          a_hash_including(foo: 'bar')
        )
      end
    end

    context 'when metadata endpoint times out' do
      let(:metadata_url) { 'url' }

      before do
        allow_any_instance_of(
          OneLogin::RubySaml::IdpMetadataParser
        ).to receive(:parse_remote_to_hash).and_raise(Timeout::Error)
      end

      it 'raises an exception' do
        expect { subject }.to raise_exception(
          StandardError, /Execution expired parsing remote metadata: `url`/
        )

        expect(Sentry).to have_received(:capture_exception).with(
          an_instance_of(StandardError)
        )
      end
    end

    context 'when metadata endpoint can be retrieved and parsed' do
      let(:metadata_url) { 'http://saml-metadata-endpoint' }
      let(:metadata_result) { { foo: 'bar' } }

      before do
        allow_any_instance_of(
          OneLogin::RubySaml::IdpMetadataParser
        ).to receive(:parse_remote_to_hash).with(metadata_url).and_return(metadata_result)
      end

      # rubocop:disable RSpec/ExampleLength
      it 'merges the configuration into the `omniauth.strategy`' do
        expect(
          subject
        ).to eq(
          {
            foo: 'bar',
            sp_entity_id: 'crime-apply',
            name_identifier_format: 'urn:oasis:names:tc:SAML:1.1:nameid-format:unspecified',
            certificate: nil,
            private_key: nil,
            idp_sso_service_binding: :redirect,
            idp_slo_service_binding: :redirect,
            single_logout_service_url: 'http://example.com/providers/auth/saml/slo',
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
              office_codes: ['LAA_ACCOUNTS']
            }
          }
        )
      end
      # rubocop:enable RSpec/ExampleLength
    end
  end
end
