require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  describe '#destroy' do
    it 'logs out the user' do
      expect(warden).to receive(:logout)
      delete :destroy
    end

    it 'redirects to the home page' do
      delete :destroy
      expect(subject).to redirect_to(root_path)
    end
  end
end
