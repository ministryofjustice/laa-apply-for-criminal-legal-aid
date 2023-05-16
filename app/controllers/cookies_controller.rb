class CookiesController < UnauthenticatedController
  def show
    @form_object = Cookies::SettingsForm.build(
      helpers.analytics_consent_cookie
    )
  end

  def update
    result = Cookies::SettingsForm.new(
      consent: consent_param,
      cookies: cookies
    ).save

    redirect_back fallback_location: root_path, flash: { cookies_consent_updated: result }
  end

  private

  def consent_param
    params.require(:cookies_settings_form).fetch(:consent)
  end
end
