module AuthHelper
  def provider_omniauth_authorize_path
    provider_entra_omniauth_authorize_path

  # :nocov:
  # Portal/SAML auth will be removed once staging users onboarded to LASSIE
  rescue NameError
    provider_saml_omniauth_authorize_path
    # :nocov:
  end

  def provider_omniauth_logout_path(locale: I18n.locale)
    return "/providers/auth/entra/logout?locale=#{locale}" if FeatureFlags.entra_logout.enabled?

    providers_logout_path
  end
end
