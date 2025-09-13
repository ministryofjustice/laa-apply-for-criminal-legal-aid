require 'omniauth'

Rails.application.config.middleware.use OmniAuth::Builder do
  configure do |config|
    config.add_mock(:entra, Silas::OidcStrategy.mock_auth)
    config.test_mode = Rails.env.test? || ENV.fetch('OMNIAUTH_TEST_MODE', 'false').inquiry.true?
  end
end
