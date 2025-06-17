module AuthHelper
  # :nocov:
  def provider_omniauth_authorize_path
    case ENV.fetch('AUTH_IDP', 'saml')
    when 'saml' then provider_saml_omniauth_authorize_path
    when 'azure_ad' then provider_azure_ad_omniauth_authorize_path
    end
  end
  # :nocov:
end
