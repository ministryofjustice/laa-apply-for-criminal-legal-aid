module Cookies
  class SettingsForm
    include ActiveModel::Model

    attr_accessor :consent, :cookies

    CONSENT_ACCEPT = 'accept'.freeze
    CONSENT_REJECT = 'reject'.freeze

    def save
      cookies[cookie_name] = {
        expires: expiration,
        value: accept_or_reject
      }

      accept_or_reject
    end

    private

    # We filter the value to ensure it is either `accept` or `reject`, and if
    # it is none of those values, we default to `reject` as a precaution.
    def accept_or_reject
      ([CONSENT_ACCEPT, CONSENT_REJECT] & Array(consent)).first || CONSENT_REJECT
    end

    def cookie_name
      Rails.configuration.x.analytics.cookies_consent_name
    end

    def expiration
      Rails.configuration.x.analytics.cookies_consent_expiration
    end
  end
end
