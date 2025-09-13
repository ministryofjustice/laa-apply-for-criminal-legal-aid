module AuthHelper
  def provider_omniauth_logout_path(locale: I18n.locale)
    return "/providers/auth/entra/logout?locale=#{locale}" if FeatureFlags.entra_logout.enabled?

    providers_logout_path
  end
end
