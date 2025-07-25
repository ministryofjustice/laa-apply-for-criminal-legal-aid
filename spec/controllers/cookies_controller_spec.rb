require 'rails_helper'

RSpec.describe CookiesController do
  describe '#show' do
    it 'renders the expected page' do
      get :show
      expect(response).to have_http_status(:ok)
    end
  end
end
