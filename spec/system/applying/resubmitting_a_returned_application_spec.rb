require 'rails_helper'

RSpec.describe 'Resubmitting a returned application' do
  describe 'Submitting a completed application' do
    include_context 'when logged in'

    let(:origional) { JSON.parse(LaaCrimeSchemas.fixture(1.0, name: 'application_returned').read) }
    let(:application_id) { '47a93336-7da6-48ec-b139-808ddd555a41' }

    before do
      stub_request(:get, "http://datastore-webmock/api/v1/applications/#{application_id}")
        .to_return(body: origional.deep_merge('provider_details' => { 'office_code' => '2A555X' }).to_json)

      visit completed_crime_application_path(application_id)
    end

    context 'when origionally passported on age' do
      it 'recreates the application' do
        click_button 'Update application'
        expect(page).to have_element('h1', text: 'Review the application')
        expect(page).to have_content 'You need to complete all questions before you can submit the application'
      end
    end
  end
end
