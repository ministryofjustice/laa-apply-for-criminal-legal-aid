require 'rails_helper'

RSpec.describe HomeController do
  describe '#index' do
    it 'renders the expected page' do
      get :index
      expect(response).to render_template(:index)
    end
  end
end
