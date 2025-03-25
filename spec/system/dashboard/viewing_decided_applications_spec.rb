require 'rails_helper'

RSpec.describe 'Viewing Decided Criminal Legal Aid applications' do
  include_context 'when logged in'
  include_context 'with stubbed search results'

  before do
    visit 'applications/decided'
  end

  it 'shows decided applications for the selected office code' do
    expect(WebMock).to have_requested(
      :post, datastore_api_endpoint
    ).with(body: hash_including(
      {
        search: {
          search_text: nil,
          review_status: [Types::ReviewApplicationStatus['assessment_completed']],
          status: nil,
          office_code: '2A555X',
          exclude_archived: true
        }
      }
    ))
  end

  context 'when there are no records to return' do
    let(:stubbed_search_results) { [] }

    it 'informs the user that there are no applications' do
      expect(page).to have_element('h2', text: 'There are no applications')
    end
  end

  it 'shows "Decided" as the current page' do
    current_tab = find(:element, 'aria-current': 'page', class: 'moj-sub-navigation__link')

    expect(current_tab).to have_text 'Decided'
  end

  it_behaves_like 'a datastore api results table'
end
