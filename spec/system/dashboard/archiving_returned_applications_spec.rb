require 'rails_helper'

RSpec.describe 'Archiving Returned Criminal Legal Aid applications' do
  include_context 'when logged in'
  include_context 'with stubbed search results'

  let(:office_code) { '1A123B' }
  let(:application_id) { '47a93336-7da6-48ec-b139-808ddd555a41' }

  let(:stubbed_search_results) do
    [
      ApplicationSearchResult.new(
        applicant_name: 'John Potter',
        resource_id: application_id,
        reference: 600_000_2,
        status: 'returned',
        review_status: 'returned_to_provider',
        submitted_at: '2022-09-27T14:10:00.889Z',
        application_type: 'initial',
      )
    ]
  end

  let(:returned_application) { LaaCrimeSchemas.fixture(1.0, name: 'application_returned') }

  before do
    stub_request(:get, "http://datastore-webmock/api/v1/applications/#{application_id}")
      .to_return(body: returned_application)

    visit 'applications/returned'
  end

  context 'when the returned application has no child drafts' do
    before do
      stub_request(:put, "http://datastore-webmock/api/v1/applications/#{application_id}/archive")
        .to_return(status: 200, body: '{}')

      within('.govuk-table__row', text: 'John Potter') do
        click_link('Delete')
      end
      click_button 'Delete application'
    end

    it 'archives the application' do
      expect(page).to have_text('John POTTER’s returned application has been deleted')
    end
  end

  context 'when the returned application has a child draft' do
    before do
      CrimeApplication.create!(
        parent_id: application_id
      )
      within('.govuk-table__row', text: 'John Potter') do
        click_link('Delete')
      end
    end

    it 'tells the user that there is a child draft application' do
      expect(page).to have_text('There is another version of this application open')
    end
  end
end
