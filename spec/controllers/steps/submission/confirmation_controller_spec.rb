require 'rails_helper'

RSpec.describe Steps::Submission::ConfirmationController, type: :controller do
  describe 'confirmation page' do
    include_context 'current provider with active office'

    let(:application_id) { '696dd4fd-b619-4637-ab42-a5f4565bcf4a' }
    let(:application_fixture) { LaaCrimeSchemas.fixture(1.0) }

    before do
      stub_request(:get, "http://datastore-webmock/api/v1/applications/#{application_id}")
        .to_return(body: application_fixture)
    end

    it 'responds with HTTP success' do
      get :show, params: { id: application_id }
      expect(response).to be_successful

      crime_app = controller.instance_variable_get(:@crime_application)

      expect(crime_app).not_to be_nil
      expect(crime_app.reference).to eq(6_000_001)
      expect(crime_app.resubmission?).to be(false)
    end
  end
end
