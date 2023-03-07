require 'rails_helper'

RSpec.describe 'Error pages' do
  context 'invalid session' do
    it 'renders the expected page and has expected status code' do
      get '/errors/invalid_session'
      expect(response).to have_http_status(:ok)
    end
  end

  context 'application not found' do
    it 'renders the expected page and has expected status code' do
      get '/errors/application_not_found'
      expect(response).to have_http_status(:not_found)
    end
  end

  context 'not found' do
    it 'renders the expected page and has expected status code' do
      get '/errors/not_found'
      expect(response).to have_http_status(:not_found)
    end
  end

  context 'unhandled' do
    it 'renders the expected page and has expected status code' do
      get '/errors/unhandled'
      expect(response).to have_http_status(:internal_server_error)
    end
  end

  context 'not_enrolled' do
    it 'renders the expected page and has expected status code' do
      get '/errors/not_enrolled'
      expect(response).to have_http_status(:forbidden)
    end
  end

  context 'unauthorized' do
    it 'renders the expected page and has expected status code' do
      get '/errors/unauthorized'
      expect(response).to have_http_status(:unauthorized)
    end

    context 'when the sign in fails' do
      before do
        allow(OmniAuth.config).to receive(:test_mode).and_return(false)
        allow_any_instance_of(LaaPortal::SamlSetup).to receive(:setup).and_raise(StandardError)
      end

      it 'redirects to the home' do
        post provider_saml_omniauth_authorize_path
        expect(response).to redirect_to(new_provider_session_path)
      end
    end
  end
end
