require 'rails_helper'

RSpec.describe 'Home' do
  describe 'index' do
    it 'renders the expected page' do
      get '/'
      expect(response).to have_http_status(:ok)
    end
  end
end
