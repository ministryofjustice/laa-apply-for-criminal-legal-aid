require 'rails_helper'

RSpec.describe 'Error pages' do
  context 'invalid session' do
    it 'renders the expected page and has expected status code' do
      get '/errors/invalid-session'
      expect(response).to have_http_status(:ok)
    end
  end

  context 'invalid token' do
    it 'renders the expected page and has expected status code' do
      get '/errors/invalid-token'
      expect(response).to have_http_status(:bad_request)
    end
  end

  context 'application not found' do
    it 'renders the expected page and has expected status code' do
      get '/errors/application-not-found'
      expect(response).to have_http_status(:not_found)
    end
  end

  context 'not found' do
    it 'renders the expected page and has expected status code' do
      get '/errors/not-found'
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
      get '/errors/not-enrolled'
      expect(response).to have_http_status(:forbidden)
    end
  end

  context 'contingent_liability' do
    it 'renders the expected page and has expected status code' do
      get '/errors/contingent-liability'
      expect(response).to have_http_status(:ok)
    end
  end

  context 'unauthenticated' do
    it 'renders the expected page and has expected status code' do
      get '/errors/unauthenticated'
      expect(response).to have_http_status(:ok)
    end
  end

  context 'reauthenticate' do
    it 'renders the expected page and has expected status code' do
      get '/errors/reauthenticate'
      expect(response).to have_http_status(:ok)
    end
  end

  context 'account_locked' do
    it 'renders the expected page and has expected status code' do
      get '/errors/account-locked'
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'double sign outs' do
    before do
      # We are already signed out, we trigger another one
      get providers_logout_path
    end

    it 'does not show any flash message' do
      expect(response).to redirect_to(root_path)
      follow_redirect!

      assert_select 'h1', 'Apply for criminal legal aid'
      assert_select 'div.govuk-notification-banner', count: 0
    end
  end
end
