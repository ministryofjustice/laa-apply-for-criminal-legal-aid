require 'rails_helper'

RSpec.describe 'Dashboard' do
  describe 'list of applications' do
    before :all do
      # sets up a few test records
      app1 = CrimeApplication.create
      app2 = CrimeApplication.create
      app3 = CrimeApplication.create

      Applicant.create(crime_application: app1, first_name: 'John', last_name: 'Doe')
      Applicant.create(crime_application: app2, first_name: '', last_name: '')
      Applicant.create(crime_application: app3)

      # sets up a valid session
      get '/steps/client/has_partner'

      # page actually under test
      get '/crime_applications'
    end

    after :all do
      # do not leave left overs in the test database
      CrimeApplication.destroy_all
    end

    it 'contains only applications having the applicant name entered' do
      expect(response).to have_http_status(:success)

      assert_select 'h1', 'Your applications'

      assert_select 'tbody.govuk-table__body' do
        assert_select 'tr.govuk-table__row', 1 do
          assert_select 'a.govuk-link', count: 1, text: 'John Doe'
        end
      end
    end
  end
end
