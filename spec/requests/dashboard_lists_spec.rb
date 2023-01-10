require 'rails_helper'

RSpec.describe 'Dashboard' do
  # Fixtures used to mock responses from the datastore
  let(:application_fixture) { LaaCrimeSchemas.fixture(1.0) }
  let(:application_fixture_id) { '696dd4fd-b619-4637-ab42-a5f4565bcf4a' }
  let(:returned_application_fixture) { LaaCrimeSchemas.fixture(1.0, name: 'application_returned') }
  let(:pagination_fixture) { { per_page: 20, total_count: 1, total_pages: 1, sort: 'desc' }.to_json }
  let(:order) { nil }

  before do
    allow_any_instance_of(
      Datastore::ApplicationCounters
    ).to receive_messages(returned_count: 5)

    # Assume we have a signed in Provider,
    # with a selected office account
    allow_any_instance_of(
      Provider
    ).to receive(:selected_office_code).and_return('1A123B')
  end

  describe 'list of in progress applications' do
    before do
      get crime_applications_path, params: { order: }
    end

    context 'when there are records to return' do
      before :all do
        # sets up a few test records
        app1 = create_test_application(created_at: Date.new(2022, 10, 15))
        app2 = create_test_application(office_code: 'XYZ') # a different office
        app3 = create_test_application(created_at: Date.new(2022, 10, 12))
        app4 = create_test_application

        Applicant.create(crime_application: app1, first_name: 'John', last_name: 'Doe')
        Applicant.create(crime_application: app2, first_name: 'Jane', last_name: 'Doe')
        Applicant.create(crime_application: app3, first_name: 'John', last_name: 'Zebra')
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
            assert_select 'td.govuk-table__cell:nth-of-type(1)', '15 Oct 2022'
            assert_select 'td.govuk-table__cell:nth-of-type(2)', /[[:digit:]]/
            assert_select 'td.govuk-table__cell:nth-of-type(3)' do
              assert_select 'button.govuk-button', count: 2, text: 'Delete'
            end
          end
        end

        expect(response.body).not_to include('Jane Doe')
      end

      context 'when the list is sorted by applicant name' do
        let(:order) { 'applicant_name' }

        it 'lists the applications by applicant name' do
          assert_select 'tbody.govuk-table__body' do
            assert_select 'tr.govuk-table__row:nth-of-type(1)' do
              assert_select 'a', count: 1, text: 'John Zebra'
            end
          end
        end
      end

      context 'when the list is sorted by created_at' do
        let(:order) { 'created_at' }

        it 'lists the applications by applicant name' do
          assert_select 'tbody.govuk-table__body' do
            assert_select 'tr.govuk-table__row:nth-of-type(1)' do
              assert_select 'a', count: 1, text: 'John Doe'
            end
          end
        end
      end

      context 'when the list is sorted by a non-allowed parameter' do
        let(:order) { 'bad_param' }

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

        assert_select 'h2', 'There are no applications in progress'
      end
    end
  end

  describe 'list of submitted applications' do
    let(:collection_fixture) do
      format(
        '{"pagination":%<pagination_fixture>s,"records":[%<application_fixture>s]}',
        pagination_fixture: pagination_fixture,
        application_fixture: application_fixture.read
      )
    end

    before do
      stub_request(:get, 'http://datastore-webmock/api/v2/applications')
        .with(query: hash_including({ 'status' => 'submitted', 'office_code' => '1A123B' }))
        .to_return(body: collection_fixture)

      get completed_crime_applications_path
    end

    it 'shows a list of submitted applications' do
      expect(response).to have_http_status(:success)

      assert_select 'h1', 'Your applications'

      assert_select '.moj-sub-navigation__list > li:nth-child(1) > a', text: 'In progress'
      assert_select '.moj-sub-navigation__list > li:nth-child(2) > a', text: 'Submitted', 'aria-current': 'page'
      assert_select '.moj-sub-navigation__list > li:nth-child(3) > a', text: 'Returned (5)'

      assert_select 'tbody.govuk-table__body' do
        assert_select 'tr.govuk-table__row', 1 do
          assert_select 'a', count: 1, text: 'Kit Pound'
        end
        assert_select 'td.govuk-table__cell:nth-of-type(1)', '24 Oct 2022'
        assert_select 'td.govuk-table__cell:nth-of-type(2)', '6000001'
      end
    end

    context 'when there are no records to return' do
      let(:collection_fixture) do
        format(
          '{"pagination":%<pagination_fixture>s,"records":[]}',
          pagination_fixture:,
        )
      end
      let(:pagination_fixture) { { per_page: 20, total_count: 0, total_pages: 0, sort: 'desc' }.to_json }

      it 'informs the user that there are no applications' do
        expect(response).to have_http_status(:success)

        assert_select 'h2', 'There are no submitted applications'
      end
    end
  end

  describe 'list of returned applications' do
    let(:collection_fixture) do
      format(
        '{"pagination":%<pagination_fixture>s,"records":[%<application_fixture>s]}',
        pagination_fixture: pagination_fixture,
        application_fixture: returned_application_fixture.read
      )
    end

    before do
      stub_request(:get, 'http://datastore-webmock/api/v2/applications')
        .with(query: hash_including({ 'status' => 'returned', 'office_code' => '1A123B' }))
        .to_return(body: collection_fixture)

      get completed_crime_applications_path(q: 'returned')
    end

    it 'shows a list of returned applications' do
      expect(response).to have_http_status(:success)

      assert_select 'h1', 'Your applications'

      assert_select '.moj-sub-navigation__list > li:nth-child(1) > a', text: 'In progress'
      assert_select '.moj-sub-navigation__list > li:nth-child(2) > a', text: 'Submitted'
      assert_select '.moj-sub-navigation__list > li:nth-child(3) > a', text: 'Returned (5)', 'aria-current': 'page'

      assert_select 'tbody.govuk-table__body' do
        assert_select 'tr.govuk-table__row', 1 do
          assert_select 'a', count: 1, text: 'John POTTER'
        end
        assert_select 'td.govuk-table__cell:nth-of-type(1)', '27 Sep 2022'
        assert_select 'td.govuk-table__cell:nth-of-type(2)', '6000002'
      end
    end

    context 'when there are no records to return' do
      let(:pagination_fixture) { { per_page: 20, total_count: 0, total_pages: 0, sort: 'desc' }.to_json }
      let(:application_fixture) { nil }

      it 'informs the user that there are no applications' do
        expect(response).to have_http_status(:success)

        assert_select 'h2', 'There are no returned applications'
      end
    end
  end
end
