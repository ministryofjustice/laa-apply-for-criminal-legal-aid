require 'rails_helper'

RSpec.describe AboutController do
  describe '#privacy' do
    it 'has a 200 response code' do
      get 'privacy'
      expect(response).to have_http_status(:ok)
    end
  end
end
