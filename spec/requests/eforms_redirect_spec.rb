require 'rails_helper'

RSpec.describe 'eForms redirect', :authorized do
  describe 'eForms redirect page' do
    before :all do
      # sets up a test record
      app = CrimeApplication.create

      # page actually under test
      get steps_client_nino_exit_path(app)
    end

    after :all do
      # do not leave left overs in the test database
      CrimeApplication.destroy_all
    end

    it 'returns the correct with success' do
      expect(response).to have_http_status(:success)
    end

    it 'returns the correct redirect link to eForms' do
      expect(response.body).to include('https://portal.legalservices.gov.uk')
    end

    context 'content sanity check' do
      it 'has the correct page heading' do
        expect(response.body).to include('Use eForms for this application')
      end
    end
  end
end
