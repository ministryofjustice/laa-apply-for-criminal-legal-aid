require 'rails_helper'

describe LaaPortalSetup do
  subject { described_class.call(env) }

  let(:env) do
    { 'omniauth.strategy' => double(options: {}) }
  end

  let(:metadata_url) { nil }

  before do
    allow(Sentry).to receive(:capture_exception)
    allow(OmniAuth.config).to receive(:test_mode).and_return(false)

    stub_const(
      'ENV',
      ENV.to_h.merge(
        'LAA_PORTAL_IDP_METADATA_URL' => metadata_url,
        'LAA_PORTAL_IDP_SSO_URL' => 'https://test.com/sso',
        'LAA_PORTAL_IDP_CERT' => '<idp_certificate>',
        'LAA_PORTAL_SP_CERT' => nil,
        'LAA_PORTAL_SP_PRIVATE_KEY' => nil,
      )
    )
  end

  describe '.setup' do
    context 'when no metadata endpoint is declared' do
      it 'uses a manual override config' do
        expect(subject).to match(
          a_hash_including(
            idp_cert: '<idp_certificate>',
            idp_sso_service_url: 'https://test.com/sso',
            idp_sso_service_binding: :redirect,
            assertion_consumer_service_binding: :post,
          )
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
            certificate: nil,
            private_key: nil,
            security: {
              authn_requests_signed: true,
              want_assertions_signed: true,
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
