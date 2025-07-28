module AuthHelper
  def provider_omniauth_authorize_path
    provider_entra_omniauth_authorize_path

  # :nocov:
  # Portal/SAML auth will be removed once staging users onboarded to LASSIE
  rescue NameError
    provider_saml_omniauth_authorize_path
    # :nocov:
  end

  def provider_omniauth_logout_path
    '/providers/auth/entra/logout'
  end
end
