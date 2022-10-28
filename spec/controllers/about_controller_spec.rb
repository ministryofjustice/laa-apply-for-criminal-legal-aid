require 'rails_helper'

RSpec.describe AboutController do
  describe '#privacy' do
    it 'has a 200 response code' do
      get 'privacy'
      expect(response).to have_http_status(:ok)
    end
  end

  describe '#contact' do
    it 'has a 200 response code' do
      get 'contact'
      expect(response).to have_http_status(:ok)
    end
  end

  describe '#feedback' do
    it 'has a 200 response code' do
      get 'feedback'
      expect(response).to have_http_status(:ok)
    end
  end

  describe '#accessibility' do
    it 'has a 200 response code' do
      get 'accessibility'
      expect(response).to have_http_status(:ok)
    end
  end
end
