require 'rails_helper'

RSpec.describe Lassie::OidcStrategy do
  let(:strategy_class) { described_class }
  let(:mock_auth) { strategy_class.mock_auth }

  describe '#info' do
    let(:laa_accounts) { %w[1A123B 2A555X 3B345C 4C567D] }

    let(:strategy_instance) do
      strategy_class.new(nil).tap do |strategy|
        allow(strategy).to receive(:user_info).and_return(
          OpenIDConnect::ResponseObject::UserInfo.new(
            :email => 'provider@example.com',
            'LAA_ACCOUNTS' => laa_accounts
          )
        )
      end
    end

    it 'returns the correct info hash' do
      expect(strategy_instance.info).to include(
        email: 'provider@example.com',
        roles: ['ACCESS_CRIME_APPLY'],
        office_codes: %w[1A123B 2A555X 3B345C 4C567D]
      )
    end

    context 'when LAA_ACCOUNTS` custom claim is a single office code (as a string)' do
      let(:laa_accounts) { '1A123B' }

      it 'normalizes the `office_codes` value to return an array' do
        expect(strategy_instance.info).to include(
          email: 'provider@example.com',
          roles: ['ACCESS_CRIME_APPLY'],
          office_codes: %w[1A123B]
        )
      end
    end

    context 'when the provider data API feature is enabled' do
      before do
        allow(FeatureFlags).to receive(:provider_data_api) {
          instance_double(FeatureFlags::EnabledFeature, enabled?: true)
        }

        allow(ProviderDataApi::ActiveOfficeCodesFilter).to receive(:call).and_return(
          %w[1A123B 3B345C]
        )
      end

      it 'filters the office codes using the active office code filter' do
        expect(strategy_instance.info[:office_codes]).to eq %w[1A123B 3B345C]

        expect(ProviderDataApi::ActiveOfficeCodesFilter).to have_received(:call).with(
          laa_accounts, area_of_law: ProviderDataApi::Types::AreaOfLaw['CRIME LOWER']
        )
      end
    end
  end

  describe 'Devise OmniAuth strategy configuration' do
    let(:strategy) { Devise.omniauth_configs.fetch(:entra).strategy }

    it 'does not use the implicit flow' do
      expect(strategy.response_type).to eq(:code)
    end

    it 'Proof Key for Code Exchange (PKCE) is enabled' do
      expect(strategy.pkce).to be(true)
    end

    it 'sets the correct logout path' do
      expect(strategy.logout_path).to match('/logout')
    end

    it 'sets the correct post logout redirect uri' do
      expect(strategy.post_logout_redirect_uri).to match('https://www.example.com/providers/logout')
    end

    it 'uses the tennant url for issuer descovery' do
      expect(strategy.discovery).to be(true)
      expect(strategy.issuer).to match(
        'https://login.microsoftonline.com/TestEntraTenantID/v2.0'
      )
    end

    it 'sets the correct client options' do
      expected_options = {
        identifier: 'TestEntraClientID',
        redirect_uri: 'https://www.example.com/users/auth/entra/callback',
        secret: 'TestEntraClientSecret',
        port: 443
      }
      expect(strategy.client_options).to include(expected_options)
    end
  end
end
