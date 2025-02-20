require 'rails_helper'

RSpec.describe 'Dashboard', :authorized do
  include_context 'with office code selected'

  before do
    allow_any_instance_of(
      Datastore::ApplicationCounters
    ).to receive_messages(returned_count: 5)
  end

  describe 'list of in progress applications' do
    let(:sort_by) { nil }
    let(:sort_direction) { nil }

    before do
      get crime_applications_path, params: { sorting: { sort_by:, sort_direction: } }
    end

    context 'when there are in progress records to return' do
      before :all do
        # sets up a few test records
        app1 = create_test_application(created_at: Date.new(2022, 10, 15))
        app2 = create_test_application(created_at: Date.new(2022, 10, 12)) # Different date
        app3 = create_test_application(office_code: 'XYZ') # a different office
        app4 = create_test_application

        Applicant.create(crime_application: app1, first_name: 'John', last_name: 'Doe')
        Applicant.create(crime_application: app2, first_name: 'John', last_name: 'Last')
        Applicant.create(crime_application: app3, first_name: 'Jane', last_name: 'Doe')
        Applicant.create(crime_application: app4, first_name: '', last_name: '')
      end

      after :all do
        # do not leave left overs in the test database
        CrimeApplication.destroy_all
      end

      it 'contains only applications having the applicant name entered' do
        expect(response).to have_http_status(:success)

        assert_select 'h1', 'Your applications'

        assert_select '.moj-sub-navigation__list > li:nth-child(1) > a', text: 'In progress (2)', 'aria-current': 'page'
        assert_select '.moj-sub-navigation__list > li:nth-child(2) > a', text: 'Submitted'
        assert_select '.moj-sub-navigation__list > li:nth-child(3) > a', text: 'Returned (5)'

        assert_select 'tbody.govuk-table__body' do
          assert_select 'tr.govuk-table__row', 2 do
            assert_select 'a', count: 1, text: 'John Doe'
            assert_select 'td.govuk-table__cell:nth-of-type(1)', '15 October 2022'
            assert_select 'td.govuk-table__cell:nth-of-type(2)', /[[:digit:]]/
            assert_select 'td.govuk-table__cell:nth-of-type(4)' do
              assert_select 'a.govuk-link', count: 2, text: 'Delete'
            end
          end
        end

        expect(response.body).not_to include('Jane Doe')
      end

      context 'when the list is sorted by created_at asc' do
        let(:sort_by) { 'created_at' }
        let(:sort_direction) { 'ascending' }

        it 'renders the correct sort indicator in the column' do
          assert_select 'thead.govuk-table__head' do
            assert_select 'th.govuk-table__header[aria-sort="ascending"]' do
              assert_select 'button', count: 1, text: 'Start date'
            end
          end
        end

        it 'lists the applications by applicant name' do
          assert_select 'tbody.govuk-table__body' do
            assert_select 'tr.govuk-table__row:nth-of-type(1)' do
              assert_select 'a', count: 1, text: 'John Last'
            end
          end
        end
      end

      context 'when the list is sorted by a non-allowed column' do
        let(:sort_by) { 'date_stamp' }

        it 'defaults to created_at' do
          assert_select 'tbody.govuk-table__body' do
            assert_select 'tr.govuk-table__row:nth-of-type(1)' do
              assert_select 'a', count: 1, text: 'John Doe'
            end
          end
        end
      end
    end

    context 'when there are no records to return' do
      it 'informs the user that there are no applications' do
        expect(response).to have_http_status(:success)

        assert_select 'h2', 'There are no applications'
      end
    end
  end

  # TODO: remove when decided_applications_tab removed
  describe 'list of submitted applications' do
    include_context 'with stubbed search results'

    before { get '/applications/submitted' }

    it 'shows submitted applications' do
      expect(response).to have_http_status(:success)
      expect(WebMock).to have_requested(
        :post, datastore_api_endpoint
      ).with(body: hash_including(
        {
          search: {
            search_text: nil,
            review_status: nil,
            status: %w[submitted returned],
            office_code: '1A123B'
          }
        }
      ))
    end

    it 'sets "Submitted" tab as current' do
      assert_select '.moj-sub-navigation__list > li:nth-child(1) > a', text: 'In progress'
      assert_select '.moj-sub-navigation__list > li:nth-child(2) > a', text: 'Submitted', 'aria-current': 'page'
      assert_select '.moj-sub-navigation__list > li:nth-child(3) > a', text: 'Returned (5)'
    end

    it 'shows a list of submitted applications' do
      assert_select 'h1', 'Your applications'

      assert_select 'tbody.govuk-table__body' do
        assert_select 'tr.govuk-table__row', 2 do
          assert_select 'a', count: 1, text: 'Kit Pound'
          assert_select 'td.govuk-table__cell:nth-of-type(1)', '27 October 2022'
          assert_select 'td.govuk-table__cell:nth-of-type(2)', '120398120'
          assert_select 'td.govuk-table__cell:nth-of-type(3)', 'Initial'
        end
      end
    end

    context 'when the office code is blank' do
      let(:selected_office_code) { '' }

      it 'redirects to the select office page' do
        expect(response).to redirect_to(steps_provider_select_office_path)
      end
    end

    context 'when there are no records to return' do
      let(:stubbed_search_results) { [] }

      it 'informs the user that there are no applications' do
        expect(response).to have_http_status(:success)

        assert_select 'h2', 'There are no applications'
      end
    end
  end
end
