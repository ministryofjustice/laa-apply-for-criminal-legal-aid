require 'rails_helper'

RSpec.describe 'Dashboard' do
  describe 'make a new application' do
    it 'creates a new `crime_application` record' do
      expect do
        post crime_applications_path
      end.to change(CrimeApplication, :count).by(1)

      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(/has_partner/)
    end
  end

  describe 'show an application certificate (in `submitted` status)' do
    before :all do
      # sets up a test record
      app = CrimeApplication.create(
        status: :submitted,
        date_stamp: Date.new(2022, 12, 25),
        submitted_at: Date.new(2022, 12, 31),
      )

      Applicant.create(crime_application: app, first_name: 'Jane', last_name: 'Doe')
    end

    after :all do
      CrimeApplication.destroy_all
    end

    before do
      applicant = Applicant.find_by(first_name: 'Jane')
      app = applicant.crime_application

      get completed_crime_application_path(app)
    end

    it 'renders the certificate page' do
      expect(response).to have_http_status(:success)

      assert_select 'h1', 'Application for criminal legal aid certificate'
    end

    it 'has appropriate CTA buttons' do
      # There is no update button
      assert_select 'button.govuk-button', count: 0, text: 'Update application'

      # There are 2 print buttons, one above the summary, another in the bottom
      assert_select 'a.govuk-button', count: 2, text: 'Print application'
    end

    it 'has the application details' do
      assert_select 'dl.govuk-summary-list:nth-of-type(1)' do
        assert_select 'div.govuk-summary-list__row:nth-of-type(1)' do
          assert_select 'dt:nth-of-type(1)', 'LAA reference:'
          assert_select 'dd:nth-of-type(1)', /^LAA-[[:alnum:]]{6}$/
        end
        assert_select 'div.govuk-summary-list__row:nth-of-type(2)' do
          assert_select 'dt:nth-of-type(1)', 'Date stamp:'
          assert_select 'dd:nth-of-type(1)', '25 December 2022 12:00am'
        end
        assert_select 'div.govuk-summary-list__row:nth-of-type(3)' do
          assert_select 'dt:nth-of-type(1)', 'Date submitted:'
          assert_select 'dd:nth-of-type(1)', '31 December 2022 12:00am'
        end
      end
    end

    it 'has a read only version of the check your answers' do
      # client details section, no change links
      assert_select 'h2', 'Client details'

      assert_select 'dl.govuk-summary-list:nth-of-type(2)' do
        assert_select 'div.govuk-summary-list__row.govuk-summary-list__row--no-actions:nth-of-type(1)' do
          assert_select 'dt:nth-of-type(1)', 'First name'
          assert_select 'dd:nth-of-type(1)', 'Jane'
        end

        assert_select 'div.govuk-summary-list__row.govuk-summary-list__row--no-actions:nth-of-type(2)' do
          assert_select 'dt:nth-of-type(1)', 'Last name'
          assert_select 'dd:nth-of-type(1)', 'Doe'
        end
      end
    end
  end

  # NOTE: this is almost identical to `submitted` state, only difference
  # is there is an `Update application` button instead of a print button.
  # No need to test everything again.
  describe 'show an application certificate (in `returned` status)' do
    before :all do
      # sets up a test record
      CrimeApplication.create(
        status: :returned,
        date_stamp: Date.new(2022, 12, 25),
        submitted_at: Date.new(2022, 12, 31),
      )
    end

    after :all do
      CrimeApplication.destroy_all
    end

    before do
      app = CrimeApplication.returned.first
      get completed_crime_application_path(app)
    end

    it 'renders the certificate page' do
      expect(response).to have_http_status(:success)

      assert_select 'h1', 'Application for criminal legal aid certificate'
    end

    it 'has appropriate CTA buttons' do
      # There is 1 update button
      assert_select 'button.govuk-button', count: 1, text: 'Update application'

      # There is 1 print button
      assert_select 'a.govuk-button', count: 1, text: 'Print application'
    end
  end

  describe 'edit an application (aka task list)' do
    before :all do
      # sets up a test record
      app = CrimeApplication.create

      Applicant.create(crime_application: app, first_name: 'Jane', last_name: 'Doe',
                       date_of_birth: Date.new(1990, 2, 1))
    end

    after :all do
      CrimeApplication.destroy_all
    end

    before do
      applicant = Applicant.find_by(first_name: 'Jane')
      app = applicant.crime_application

      get edit_crime_application_path(app)
    end

    it 'shows the task list for the application' do
      expect(response).to have_http_status(:success)

      assert_select 'h1', 'Make a new application'
      assert_select 'h2', 'Application incomplete'

      # aside details
      assert_select 'div.govuk-grid-column-one-third aside', 1 do
        assert_select 'h3:nth-of-type(1)', 'Reference number'
        assert_select 'p:nth-of-type(1)', /^LAA-[[:alnum:]]{6}$/

        assert_select 'h3:nth-of-type(2)', 'First name'
        assert_select 'p:nth-of-type(2)', 'Jane'

        assert_select 'h3:nth-of-type(3)', 'Last name'
        assert_select 'p:nth-of-type(3)', 'Doe'

        assert_select 'h3:nth-of-type(4)', 'Date of birth'
        assert_select 'p:nth-of-type(4)', '1 Feb 1990'
      end
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

      assert_select 'a.moj-sub-navigation__link', text: 'In progress (1)', 'aria-current': 'page'
      assert_select 'a.moj-sub-navigation__link', text: 'Submitted'
      assert_select 'a.moj-sub-navigation__link', text: 'Returned'

      assert_select 'tbody.govuk-table__body' do
        assert_select 'tr.govuk-table__row', 1 do
          assert_select 'a', count: 1, text: 'John Doe'
          assert_select 'button.govuk-button', count: 1, text: 'Delete'
          assert_select 'strong.govuk-tag', count: 1, text: 'In progress'
        end
      end

      expect(response.body).not_to include('Jane Doe')
    end
  end

  describe 'list of submitted applications' do
    before :all do
      # sets up a few test records
      app1 = CrimeApplication.create(status: 'submitted')
      app2 = CrimeApplication.create
      app3 = CrimeApplication.create

      Applicant.create(crime_application: app1, first_name: 'John', last_name: 'Doe')
      Applicant.create(crime_application: app2, first_name: '', last_name: '')
      Applicant.create(crime_application: app3)

      # page actually under test
      get completed_crime_applications_path
    end

    after :all do
      # do not leave left overs in the test database
      CrimeApplication.destroy_all
    end

    it 'contains only applications having the applicant name entered' do
      expect(response).to have_http_status(:success)

      assert_select 'h1', 'Your applications'

      assert_select 'a.moj-sub-navigation__link', text: 'In progress'
      assert_select 'a.moj-sub-navigation__link', text: 'Submitted', 'aria-current': 'page'
      assert_select 'a.moj-sub-navigation__link', text: 'Returned'

      assert_select 'tbody.govuk-table__body' do
        assert_select 'tr.govuk-table__row', 1 do
          assert_select 'a', count: 1, text: 'John Doe'
          assert_select 'strong.govuk-tag', count: 1, text: 'Submitted'
        end
      end

      expect(response.body).not_to include('Jane Doe')
    end
  end

  describe 'list of returned applications' do
    before :all do
      # sets up a few test records
      app1 = CrimeApplication.create(status: 'returned')
      app2 = CrimeApplication.create
      app3 = CrimeApplication.create

      Applicant.create(crime_application: app1, first_name: 'John', last_name: 'Doe')
      Applicant.create(crime_application: app2, first_name: '', last_name: '')
      Applicant.create(crime_application: app3)

      # page actually under test
      get completed_crime_applications_path(q: 'returned')
    end

    after :all do
      # do not leave left overs in the test database
      CrimeApplication.destroy_all
    end

    it 'contains only applications having the applicant name entered' do
      expect(response).to have_http_status(:success)

      assert_select 'h1', 'Your applications'

      assert_select 'a.moj-sub-navigation__link', text: 'In progress'
      assert_select 'a.moj-sub-navigation__link', text: 'Submitted'
      assert_select 'a.moj-sub-navigation__link', text: 'Returned (1)', 'aria-current': 'page'

      assert_select 'tbody.govuk-table__body' do
        assert_select 'tr.govuk-table__row', 1 do
          assert_select 'a', count: 1, text: 'John Doe'
          assert_select 'strong.govuk-tag', count: 1, text: 'Returned'
        end
      end

      expect(response.body).not_to include('Jane Doe')
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
      applicant = Applicant.find_by(first_name: 'Jane')
      app = applicant.crime_application

      get confirm_destroy_crime_application_path(app)

      expect(response.body).to include('Are you sure you want to delete Jane Doe’s application?')
      expect(response.body).to include('Yes, delete it')
      expect(response.body).to include('No, do not delete it')
    end

    it 'can delete an application' do
      applicant = Applicant.find_by(first_name: 'Jane')
      app = applicant.crime_application

      expect do
        delete crime_application_path(app)
      end.to change(CrimeApplication, :count).by(-1)

      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(crime_applications_path)

      follow_redirect!

      assert_select 'div.govuk-notification-banner--success', 1 do
        assert_select 'h2', 'Success'
        assert_select 'p', 'Jane Doe’s application has been deleted'
      end
    end
  end
end
