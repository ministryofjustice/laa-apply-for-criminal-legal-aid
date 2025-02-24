require 'rails_helper'

RSpec.shared_examples 'a datastore api results table' do
  let(:current_page) { 1 }

  let(:datastore_response) do
    pagination = Pagination.new(
      current_page: current_page,
      total_count: 101,
      total_pages: 3,
      limit_value: 50
    ).attributes

    records = stubbed_search_results.map(&:attributes)

    { pagination:, records: }.deep_stringify_keys
  end

  context 'when on the first page' do
    it 'shows a link for each page and next' do
      within('nav.govuk-pagination') do
        expect(page).to have_no_button('Previous')

        %w[1 2 3 Next].each do |link_text|
          expect(page).to have_button(link_text)
        end
      end
    end
  end

  context 'when on the last page' do
    let(:current_page) { 3 }

    it 'shows a link to the previous page' do
      within('nav.govuk-pagination') do
        expect(page).to have_no_button('Next')
        expect(page).to have_button('Previous')
      end
    end

    describe 'clicking Previous' do
      it 'shows the next page' do
        within('nav.govuk-pagination') { click_button('Previous') }

        expect(WebMock).to have_requested(
          :post, datastore_api_endpoint
        ).with(body: hash_including(
          {
            pagination: { page: 2, per_page: 30 },
            sorting:  { sort_by: 'submitted_at', sort_direction: 'descending' }
          }
        ))
      end

      it 'preserves sorting' do
        click_button 'Name'
        within('nav.govuk-pagination') { click_button('Previous') }

        expect(WebMock).to have_requested(
          :post, datastore_api_endpoint
        ).with(body: hash_including(
          {
            pagination: { page: 2, per_page: 30 },
            sorting:  { sort_by: 'applicant_name', sort_direction: 'ascending' }
          }
        ))
      end
    end
  end

  describe 'clicking a page' do
    it 'shows the clicked page' do
      within('nav.govuk-pagination') { click_button('3') }

      expect(WebMock).to have_requested(
        :post, datastore_api_endpoint
      ).with(body: hash_including({ pagination: { page: 3, per_page: 30 } }))
    end

    it 'preserves sorting' do
      click_button 'LAA reference'
      within('nav.govuk-pagination') { click_button('3') }

      expect(WebMock).to have_requested(
        :post, datastore_api_endpoint
      ).with(body: hash_including(
        {
          pagination: { page: 3, per_page: 30 },
          sorting:  { sort_by: 'reference', sort_direction: 'ascending' }
        }
      ))
    end
  end

  describe 'clicking Next' do
    it 'shows the next page' do
      within('nav.govuk-pagination') { click_button('Next') }

      expect(WebMock).to have_requested(
        :post, datastore_api_endpoint
      ).with(body: hash_including({ pagination: { page: 2, per_page: 30 } }))
    end

    it 'preserves sorting' do
      click_button 'Application type'
      within('nav.govuk-pagination') { click_button('Next') }

      expect(WebMock).to have_requested(
        :post, datastore_api_endpoint
      ).with(body: hash_including(
        {
          pagination: { page: 2, per_page: 30 },
          sorting:  { sort_by: 'application_type', sort_direction: 'ascending' }
        }
      ))
    end
  end

  it 'is sorted by submitted at descending by default' do
    expect(WebMock).to have_requested(:post, datastore_api_endpoint).with(
      body: hash_including({ sorting: { sort_by: 'submitted_at', sort_direction: 'descending' } })
    )
  end

  it 'sort direction can be reversed' do
    click_button 'Date submitted'

    expect(WebMock).to have_requested(:post, datastore_api_endpoint).with(
      body: hash_including({ sorting: { sort_by: 'submitted_at', sort_direction: 'ascending' } })
    )
  end
end
