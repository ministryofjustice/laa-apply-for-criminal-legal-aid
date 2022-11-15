require 'rails_helper'

RSpec.describe Steps::Submission::ConfirmationController, type: :controller do
  describe 'confirmation page' do
    it 'responds with HTTP success' do
      get :show, params: { id: 'uuid', reference: '123' }
      expect(response).to be_successful

      reference = controller.instance_variable_get(:@reference)

      expect(reference).to eq(123)
    end

    it 'sanitises the reference' do
      get :show, params: { id: 'uuid', reference: "'<script>alert('boom!');</script>'" }
      expect(response).to be_successful

      reference = controller.instance_variable_get(:@reference)

      expect(reference).to eq(0)
    end
  end
end
