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
      app1 = create_test_application(created_at: Date.new(2022, 10, 15))
      app2 = create_test_application(created_at: Date.new(2022, 10, 12)) # Different date
      app3 = create_test_application(office_code: 'XYZ') # a different office
      app4 = create_test_application

      Applicant.create(crime_application: app1, first_name: 'John', last_name: 'Doe')
      Applicant.create(crime_application: app2, first_name: 'John', last_name: 'Last')
      Applicant.create(crime_application: app3, first_name: 'Jane', last_name: 'Doe')
      Applicant.create(crime_application: app4, first_name: '', last_name: '')

      get crime_applications_path, params: { sorting: { sort_by:, sort_direction: } }
    end

    after do
      # do not leave leftovers in the test database
      CrimeApplication.destroy_all
    end

    context 'when there are in progress records to return' do
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
    end
  end
end
