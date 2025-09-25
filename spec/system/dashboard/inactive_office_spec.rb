require 'rails_helper'

RSpec.describe 'Viewing dashboard with an office that becomes inactive' do
  include_context 'when logged in'
  include_context 'with stubbed search results'

  before do
    allow(FeatureFlags).to receive(:provider_data_api) {
      instance_double(FeatureFlags::EnabledFeature, enabled?: true)
    }

    stub_request(:get, 'https://pda.example.com/provider-offices/2A555X/schedules?areaOfLaw=CRIME%20LOWER')
      .to_return_json(status: 200, body: file_fixture('provider_data_api/public_defender_service.json').read)

    visit('/')
  end

  it 'redirects to the select office page' do
    expect(page).not_to have_content('Select your office account number')

    stub_request(:get, 'https://pda.example.com/provider-offices/2A555X/schedules?areaOfLaw=CRIME%20LOWER')
      .to_return_json(status: 200, body: file_fixture('provider_data_api/prison_only.json').read)

    visit current_path

    expect(page).to have_content('Select your office account number')
  end
end
