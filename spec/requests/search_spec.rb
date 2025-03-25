require 'rails_helper'

RSpec.describe 'Search', :authorized do
  include_context 'with office code selected'
  include_context 'with stubbed search results'

  describe 'Search form' do
    before do
      get new_application_searches_path
    end

    it 'displays search form' do
      assert_select 'h1', 'Search submitted applications'
      assert_select 'div.govuk-grid-column-full p',
                    'You are searching submitted and returned applications under office code 1A123B.'
      assert_select '.search .govuk-fieldset .input-group',
                    'Enter any combination of client first name, last name, LAA reference'
    end
  end

  describe 'list of submitted and returned applications' do
    before do
      post search_application_searches_path, params: { filter: { 'search_text' => '' } }
    end

    it 'shows submitted applications' do
      expect(response).to have_http_status(:success)
      expect(WebMock).to have_requested(
        :post, datastore_api_endpoint
      ).with(body: hash_including(
        {
          search: {
            search_text: '',
            review_status: nil,
            status: %w[submitted returned],
            office_code: '1A123B',
            exclude_archived: true
          }
        }
      ))
    end

    it 'shows a list of submitted applications' do
      expect(response).to have_http_status(:success)

      assert_select 'h1', 'Search submitted applications'
      assert_select 'h2', '2 search results'

      assert_select 'tbody.govuk-table__body' do
        assert_select 'tr.govuk-table__row', 2 do
          assert_select 'a', count: 1, text: 'Kit Pound'
          assert_select 'td.govuk-table__cell:nth-of-type(1)', '27 October 2022'
          assert_select 'td.govuk-table__cell:nth-of-type(2)', '120398120'
          assert_select 'td.govuk-table__cell:nth-of-type(3)', 'Initial'
          assert_select 'td.govuk-table__cell:nth-of-type(4)', 'Decided'
        end
      end

      assert_select '.govuk-pagination__next button.app-button--link'
    end

    it 'includes the correct results table headings' do
      assert_select 'thead' do
        assert_select 'tr th.govuk-table__header', 5 do
          assert_select 'button', count: 1, text: 'Name'
          assert_select 'button', count: 1, text: 'Date submitted'
          assert_select 'button', count: 1, text: 'LAA reference'
          assert_select 'button', count: 1, text: 'Application type'
          assert_select 'button', count: 1, text: 'Application status'
        end
      end
    end

    context 'when there are no records to return' do
      let(:stubbed_search_results) { [] }

      it 'informs the user that there are no applications' do
        expect(response).to have_http_status(:success)

        assert_select 'h1', 'Search submitted applications'
        assert_select 'h2', 'There are no results that match the criteria'
      end
    end
  end
end
