require 'rails_helper'

RSpec.describe CookiesController do
  describe '#show' do
    before do
      allow(controller.helpers).to receive(:analytics_consent_cookie).and_return('foobar')
    end

    it 'renders the expected page' do
      expect(
        Cookies::SettingsForm
      ).to receive(:build).with('foobar').and_call_original

      get :show
      expect(response).to have_http_status(:ok)
    end
  end

  describe '#update' do
    let(:param_value) { Cookies::SettingsForm::CONSENT_ACCEPT }

    # NOTE: there are more in deep tests in `spec/forms/cookies/settings_form_spec.rb`
    it 'saves the form and redirects setting the flash' do
      expect(
        Cookies::SettingsForm
      ).to receive(:new).with(
        consent: param_value,
        cookies: an_instance_of(ActionDispatch::Cookies::CookieJar),
      ).and_call_original

      post :update, params: { cookies_settings_form: { consent: param_value } }

      expect(flash[:cookies_consent_updated]).to eq(param_value)
      expect(response).to redirect_to(root_path)
    end

    context 'when the google analytics feature flag is not enabled' do
      before do
        allow(FeatureFlags).to receive(:google_analytics) {
          instance_double(FeatureFlags::EnabledFeature, enabled?: false)
        }
      end

      it 'saves the form and redirects setting the flash' do
        expect(
          Cookies::SettingsForm
        ).not_to receive(:new).with(
          consent: param_value,
          cookies: an_instance_of(ActionDispatch::Cookies::CookieJar),
          ).and_call_original

        post :update, params: { cookies_settings_form: { consent: param_value } }

        expect(flash[:cookies_consent_updated]).not_to eq(param_value)
        expect(response).not_to redirect_to(root_path)
      end
    end
  end
end
