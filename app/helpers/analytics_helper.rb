module AnalyticsHelper
  def analytics_tracking_id
    Rails.configuration.x.analytics.ga_tracking_id
  end

  def analytics_consent_cookie
    cookies[Rails.configuration.x.analytics.cookies_consent_name]
  end

  def analytics_consent_accepted?
    analytics_consent_cookie.eql?(Cookies::SettingsForm::CONSENT_ACCEPT)
  end

  def analytics_allowed?
    FeatureFlags.google_analytics.enabled? && analytics_tracking_id.present? && analytics_consent_accepted?
  end
end
