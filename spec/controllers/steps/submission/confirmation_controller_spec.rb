require 'rails_helper'

RSpec.describe Steps::Submission::ConfirmationController, type: :controller do
  describe 'confirmation page' do
    it 'responds with HTTP success' do
      get :show, params: { id: '123-uuid-567', reference: 'LAA-123456' }
      expect(response).to be_successful

      reference = controller.instance_variable_get(:@reference)

      expect(reference).to eq('LAA-123456')
    end

    it 'sanitises the reference' do
      get :show, params: { id: '123-uuid-567', reference: "'<script>alert('boom!');</script>'" }
      expect(response).to be_successful

      reference = controller.instance_variable_get(:@reference)

      expect(reference).to eq('scriptalertboomscript')
    end
  end
end
