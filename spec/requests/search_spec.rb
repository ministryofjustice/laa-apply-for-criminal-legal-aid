require 'rails_helper'

RSpec.describe 'Search', :authorized do
  include_context 'with office code selected'

  let(:stubbed_search_results) do
    [
      ApplicationSearchResult.new(
        applicant_name: 'Kit Pound',
        resource_id: '696dd4fd-b619-4637-ab42-a5f4565bcf4a',
        reference: 120_398_120,
        status: 'submitted',
        submitted_at: '2022-10-27T14:09:11.000+00:00',
        application_type: 'initial',
      ),
      ApplicationSearchResult.new(
        applicant_name: 'Don JONES',
        resource_id: '1aa4c689-6fb5-47ff-9567-5eee7f8ac2cc',
        reference: 1_230_234_359,
        status: 'returned',
        submitted_at: '2022-11-11T16:58:15.000+00:00',
        application_type: 'initial',
      ),
    ]
  end

  let(:datastore_response) do
    pagination = Pagination.new(
      total_count: stubbed_search_results.size,
      total_pages: 1,
      limit_value: 50
    ).attributes

    records = stubbed_search_results.map(&:attributes)

    { pagination:, records: }.deep_stringify_keys
  end

  let(:body) do
    { 'search' => { 'search_text' => '', 'status' => %w[submitted returned], 'office_code' => '1A123B' },
     'pagination' => { 'page' => nil, 'per_page' => nil },
     'sorting' => { 'sort_direction' => 'descending', 'sort_by' => 'submitted_at' } }.to_json
  end

  describe 'Search form' do
    before do
      get new_application_searches_path
    end

    it 'displays search form' do
      assert_select 'h1', 'Search for an application'
      assert_select 'div.govuk-grid-column-full p',
                    'You are searching for applications submitted and returned under office code 1A123B.'
      assert_select '.search .govuk-fieldset .input-group',
                    "For example, reference number or applicant's first or last name"
    end
  end

  describe 'list of submitted and returned applications' do
    before do
      stub_request(:post, 'http://datastore-webmock/api/v1/searches')
        .with(body:).to_return(body: datastore_response.to_json)

      get search_application_searches_path, params: { filter: { 'search_text' => '' } }
    end

    it 'shows a list of submitted applications' do
      expect(response).to have_http_status(:success)

      assert_select 'h1', 'Search for an application'
      assert_select 'h2', '2 search results'

      assert_select 'tbody.govuk-table__body' do
        assert_select 'tr.govuk-table__row', 2 do
          assert_select 'a', count: 1, text: 'Kit Pound'
        end
        assert_select 'td.govuk-table__cell:nth-of-type(1)', '27 October 2022'
        assert_select 'td.govuk-table__cell:nth-of-type(2)', '120398120'
        assert_select 'td.govuk-table__cell:nth-of-type(3)', 'Initial'
        assert_select 'td.govuk-table__cell:nth-of-type(4)', 'Submitted'
      end
    end

    it 'includes the correct results table headings' do
      assert_select 'thead' do
        assert_select 'tr th.govuk-table__header', 5 do
          assert_select 'button', count: 1, text: 'Name'
          assert_select 'button', count: 1, text: 'Date submitted'
          assert_select 'button', count: 1, text: 'Reference number'
          assert_select 'button', count: 1, text: 'Application type'
          assert_select 'th', count: 1, text: 'Application status'
        end
      end
    end

    context 'when there are no records to return' do
      let(:stubbed_search_results) { [] }

      it 'informs the user that there are no applications' do
        expect(response).to have_http_status(:success)

        assert_select 'h1', 'Search for an application'
        assert_select 'h2', 'There are no results that match the criteria'
      end
    end
  end
end
