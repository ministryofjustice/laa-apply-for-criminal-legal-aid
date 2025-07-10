require 'rails_helper'

RSpec.describe Lassie::OidcStrategy do
  let(:strategy_class) { described_class }
  let(:mock_auth) { strategy_class.mock_auth }

  describe '#info' do
    let(:strategy_instance) do
      strategy_class.new(nil).tap do |strategy|
        allow(strategy).to receive(:user_info).and_return(
          OpenIDConnect::ResponseObject::UserInfo.new(
            :email => 'provider@example.com',
            'LAA_ACCOUNTS' => %w[1A123B 2A555X 3B345C 4C567D]
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
  end

  describe 'Devise OmniAuth strategy configuration' do
    let(:strategy) { Devise.omniauth_configs.fetch(:entra).strategy }

    it 'does not use the implicit flow' do
      expect(strategy.response_type).to eq(:code)
    end

    it 'Proof Key for Code Exchange (PKCE) is enabled' do
      expect(strategy.pkce).to be(true)
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
