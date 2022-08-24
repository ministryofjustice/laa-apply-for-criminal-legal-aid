require 'rails_helper'

RSpec.describe 'Dashboard' do
  describe 'make a new application' do
    it 'creates a new `crime_application` record' do
      expect {
        post crime_applications_path
      }.to change { CrimeApplication.count }.by(1)

      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(/has_partner/)
    end
  end

  describe 'edit an application (aka task list)' do
    before :all do
      # sets up a test record
      app = CrimeApplication.create

      Applicant.create(crime_application: app, first_name: 'Jane', last_name: 'Doe')
    end

    after :all do
      CrimeApplication.destroy_all
    end

    it 'shows the task list for the application' do
      applicant = Applicant.find_by(first_name: 'Jane')
      app = applicant.crime_application

      get edit_crime_application_path(app)

      expect(response).to have_http_status(:success)

      assert_select 'h1', 'Make a new application'
      assert_select 'h2', 'Application incomplete'
    end
  end

  describe 'list of applications' do
    before :all do
      # sets up a few test records
      app1 = CrimeApplication.create(status: 'in_progress')
      app2 = CrimeApplication.create
      app3 = CrimeApplication.create

      Applicant.create(crime_application: app1, first_name: 'John', last_name: 'Doe')
      Applicant.create(crime_application: app2, first_name: '', last_name: '')
      Applicant.create(crime_application: app3)

      # page actually under test
      get crime_applications_path
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
          assert_select 'a', count: 1, text: 'John Doe'
          assert_select 'button.govuk-button', count: 1, text: 'Delete'
          assert_select 'strong.govuk-tag', count: 1, text: 'In progress'
        end
      end

      expect(response.body).to_not include('Jane Doe')
      expect(response.body).to_not include('INITIALISED')
    end
  end

  describe 'deleting applications' do
    before :all do
      # sets up a few test records
      app = CrimeApplication.create(status: 'in_progress')

      Applicant.create(crime_application: app, first_name: 'Jane', last_name: 'Doe')
    end

    after :all do
      CrimeApplication.destroy_all
    end

    it 'allows a user to check before deleting an application' do
      applicant = Applicant.find_by(first_name: "Jane")
      app = applicant.crime_application

      get confirm_destroy_crime_application_path(app)

      expect(response.body).to include("Are you sure you want to delete #{applicant.full_name}’s application?")
      expect(response.body).to include("Yes, delete it")
      expect(response.body).to include("No, do not delete it")
    end

    it 'can delete an application' do
      applicant = Applicant.find_by(first_name: "Jane")
      app = applicant.crime_application

      expect {
        delete crime_application_path(app)
      }.to change { CrimeApplication.count }.by(-1)

      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(crime_applications_path)

      follow_redirect!

      assert_select 'div.govuk-notification-banner--success', 1 do
        assert_select 'h2', 'Success'
        assert_select 'p', 'Jane Doe’s application has been permanently deleted'
      end
    end
  end
end
