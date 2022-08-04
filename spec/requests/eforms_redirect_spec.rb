require 'rails_helper'

RSpec.describe 'eForms redirect' do
  describe 'eForms redirect page' do
    before :all do
      # sets up a valid session
      get '/steps/client/has_partner'

      # page actually under test
      get '/steps/client/nino_exit'
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
