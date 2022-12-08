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

  context 'unauthorized' do
    it 'renders the expected page and has expected status code' do
      get '/errors/unauthorized'
      expect(response).to have_http_status(:ok)
    end
  end
end
