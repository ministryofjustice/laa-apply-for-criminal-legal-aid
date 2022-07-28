require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  describe '#destroy' do
    it 'resets the session' do
      expect(subject).to receive(:reset_session)
      delete :destroy
    end

    it 'redirects to the home page' do
      delete :destroy
      expect(subject).to redirect_to(root_path)
    end
  end
end
