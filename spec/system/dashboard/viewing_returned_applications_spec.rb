require 'rails_helper'

RSpec.describe 'Viewing Returned Criminal Legal Aid applications' do
  include_context 'when logged in'
  include_context 'with stubbed search results'

  before do
    visit 'applications/returned'
  end

  it 'shows returned applications for the selected office code' do
    expect(WebMock).to have_requested(
      :post, datastore_api_endpoint
    ).with(body: hash_including(
      {
        search: {
          search_text: nil,
          review_status: nil,
          status: [Types::ApplicationStatus['returned']],
          office_code: '2A555X'
        }
      }
    ))
  end

  context 'when there are no records to return' do
    let(:stubbed_search_results) { [] }

    it 'informs the user that there are no applications' do
      expect(page).to have_element('h2', text: 'There are no applications')
    end

    it 'does not include a visually hidden caption indicating columns are sortable' do
      expect(page).to have_no_css('table.govuk-table caption span.govuk-visually-hidden')
    end
  end

  it 'shows "Returned" as the current page' do
    current_tab = find(:element, 'aria-current': 'page', class: 'moj-sub-navigation__link')

    expect(current_tab).to have_text 'Returned'
  end

  it 'includes a visually hidden caption indicating columns are sortable' do
    expect(page).to have_css('table caption span.govuk-visually-hidden',
                             text: 'Column headers with buttons are sortable.')
  end

  it_behaves_like 'a datastore api results table'
end
