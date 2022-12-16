require 'omniauth'
require 'laa_portal_setup'

Rails.application.config.middleware.use OmniAuth::Builder do
  configure do |config|
    config.add_mock(:saml, LaaPortalSetup.mock_auth)
    config.test_mode = Rails.env.test? || ENV.fetch('OMNIAUTH_TEST_MODE', 'false').inquiry.true?
  end
end
