RSpec.shared_context 'with mock provider data' do
  before do
    mock_pda('1A123B', fixture: 'public_defender_service')
    mock_pda('A1', fixture: 'public_defender_service')
    mock_pda('2A555X', fixture: 'public_defender_service')
    mock_pda('3B345C', fixture: 'public_defender_service')
    mock_pda('AN0THR', fixture: 'public_defender_service')
    mock_pda('4C567D', status: 204)
  end

  def mock_pda(office_code, status: 200, fixture: nil)
    body = if fixture
             file_fixture("provider_data_api/#{fixture}.json").read
           else
             {}
           end

    stub_request(:get, "https://pda.example.com/provider-offices/#{office_code}/schedules?areaOfLaw=CRIME%20LOWER")
      .to_return_json(status:, body:)
  end
end
