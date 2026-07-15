# frozen_string_literal: true

require 'omniauth'

# OmniAuth persists request query parameters into the session before redirecting
# to the identity provider.
#
# Production diagnostics identified malformed `locale` parameters exceeding 2 KB,
# causing the cookie-backed session to exceed the browser's 4 KB cookie limit.
#
# The application only supports the configured I18n locales, so discard any
# invalid locale before OmniAuth writes the request parameters into the session.
strip_invalid_omniauth_locale = lambda do |env|
  session = env['rack.session']
  next unless session.respond_to?(:[])

  omniauth_params = session['omniauth.params']
  next unless omniauth_params.is_a?(Hash)

  locale = omniauth_params['locale']
  next unless locale.is_a?(String)

  allowed_locales = I18n.available_locales.map(&:to_s)
  next if allowed_locales.include?(locale)

  omniauth_params.delete('locale')
end

Rails.application.config.middleware.use OmniAuth::Builder do
  configure do |config|
    config.add_mock(:entra, Silas::OidcStrategy.mock_auth)
    config.test_mode = Rails.env.test? ||
                       ENV.fetch('OMNIAUTH_TEST_MODE', 'false').inquiry.true?

    config.before_request_phase = strip_invalid_omniauth_locale
  end
end
