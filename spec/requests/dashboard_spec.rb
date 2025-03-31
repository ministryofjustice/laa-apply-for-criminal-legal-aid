require 'rails_helper'

RSpec.describe 'Dashboard', :authorized do
  include_context 'with office code selected'

  # Fixtures used to mock responses from the datastore
  let(:application_fixture) { LaaCrimeSchemas.fixture(1.0) }
  let(:application_fixture_id) { '696dd4fd-b619-4637-ab42-a5f4565bcf4a' }
  let(:returned_application_fixture) { LaaCrimeSchemas.fixture(1.0, name: 'application_returned') }
  let(:returned_application_fixture_id) { '47a93336-7da6-48ec-b139-808ddd555a41' }

  describe 'start a new application' do
    it 'shows the new application or change in financial circumstances form' do
      expect { get new_crime_application_path }.not_to change(CrimeApplication, :count)
      assert_select 'h1', 'Are you making a new application or telling us about a change in financial circumstances?'
    end

    it 'creates a new `crime_application` record and redirects to the task list when user selects new application' do
      params = { start_is_cifc_form: { is_cifc: 'no' } }

      expect { post crime_applications_path, params: }.to change(CrimeApplication, :count).by(1)
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(/edit/)
    end

    it 'creates a new `crime_application` record and redirects user to enter the original reference number' do
      params = { start_is_cifc_form: { is_cifc: 'yes' } }

      expect { post crime_applications_path, params: }.to change(CrimeApplication, :count).by(1)
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(/pre-cifc-reference-number/)
    end
  end

  describe 'show an application representation order (in `submitted` status)' do
    before do
      stub_request(:get, "http://datastore-webmock/api/v1/applications/#{application_fixture_id}")
        .to_return(body: application_fixture)

      get completed_crime_application_path(application_fixture_id)
    end

    it 'renders the representation order page' do
      expect(response).to have_http_status(:success)

      assert_select 'h2', 'Application for a criminal legal aid representation order'
    end

    it 'has print buttons' do
      assert_select 'a.govuk-button', count: 2, text: 'Print application'
    end

    it 'does not have an update application button' do
      assert_select 'button.govuk-button', count: 0, text: 'Update application'
    end

    it 'does not have a button to "Upload supporting evidence"' do
      assert_select 'button.govuk-button', count: 0, text: 'Upload supporting evidence'
    end

    context 'when the application has been reviewed' do
      let(:application_fixture) do
        LaaCrimeSchemas.fixture(1.0) do |data|
          data.merge(reviewed_at: '2025-02-01', review_status: 'assessment_completed').to_json
        end
      end

      it 'has a button to "Upload supporting evidence"' do
        assert_select 'button.govuk-button', count: 1, text: 'Upload supporting evidence'
      end

      it 'shows funding decision notification if decisions are empty' do
        assert_select 'strong.govuk-tag.govuk-tag--blue', 'Decided'

        assert_select 'div.govuk-notification-banner' do
          assert_select 'h2', 'Important'
          assert_select 'p.govuk-notification-banner__heading', 'Outcome decided'
          assert_select 'p', 'This application was processed on 1 February 2025.'
          assert_select 'p', 'Funding decisions made after 12 midday 13 February 2025 will appear in this service.'
        end
      end

      it 'creates a new PSE application' do
        expect do
          post create_pse_completed_crime_application_path(application_fixture_id)
        end.to change(CrimeApplication.where(parent_id: application_fixture_id), :count).from(0).to(1)

        expect(response).to have_http_status(:redirect)

        follow_redirect!

        assert_select 'h1', 'Upload supporting evidence'
      end
    end

    # rubocop:disable RSpec/ExampleLength
    it 'has the application details' do
      assert_select 'dl.govuk-summary-list:nth-of-type(1)' do
        assert_select 'div.govuk-summary-list__row:nth-of-type(1)' do
          assert_select 'dt:nth-of-type(1)', 'Application type'
          assert_select 'dd:nth-of-type(1)', 'Initial'
        end
        assert_select 'div.govuk-summary-list__row:nth-of-type(2)' do
          assert_select 'dt:nth-of-type(1)', 'LAA reference number'
          assert_select 'dd:nth-of-type(1)', '6000001'
        end
        assert_select 'div.govuk-summary-list__row:nth-of-type(3)' do
          assert_select 'dt:nth-of-type(1)', 'Means tested application'
          assert_select 'dd:nth-of-type(1)', 'Yes'
        end
        assert_select 'div.govuk-summary-list__row:nth-of-type(4)' do
          assert_select 'dt:nth-of-type(1)', 'Date stamp'
          assert_select 'dd:nth-of-type(1)', '24 October 2022 10:50am'
        end
        assert_select 'div.govuk-summary-list__row:nth-of-type(5)' do
          assert_select 'dt:nth-of-type(1)', 'Date submitted'
          assert_select 'dd:nth-of-type(1)', '24 October 2022 10:50am'
        end
        assert_select 'div.govuk-summary-list__row:nth-of-type(6)' do
          assert_select 'dt:nth-of-type(1)', 'Submitted by'
          assert_select 'dd:nth-of-type(1)', 'provider@example.com'
        end
        assert_select 'div.govuk-summary-list__row:nth-of-type(7)' do
          assert_select 'dt:nth-of-type(1)', 'Office account number'
          assert_select 'dd:nth-of-type(1)', '1A123B'
        end
      end
    end
    # rubocop:enable RSpec/ExampleLength

    it 'has a read only version of the check your answers' do
      # client details section, no change links
      assert_select 'h2', 'Client details'

      assert_select 'dl.govuk-summary-list' do
        assert_select 'div.govuk-summary-list__row.govuk-summary-list__row--no-actions:nth-of-type(1)' do
          assert_select 'dt:nth-of-type(1)', 'First name'
          assert_select 'dd:nth-of-type(1)', 'Kit'
        end

        assert_select 'div.govuk-summary-list__row.govuk-summary-list__row--no-actions:nth-of-type(2)' do
          assert_select 'dt:nth-of-type(1)', 'Last name'
          assert_select 'dd:nth-of-type(1)', 'Pound'
        end
      end
    end

    context 'when the application\'s office code differs from the one selected' do
      let(:selected_office_code) { 'AN0THR' }

      it 'redirects to page not found' do
        expect(response).to redirect_to(application_not_found_errors_path)
      end
    end
  end

  describe 'show split case return reason notification banner' do
    # NOTE: the return reason notification banner has different wording for
    # returned applications marked as split_case

    let(:app_split_case) do
      LaaCrimeSchemas.fixture(1.0, name: 'application_returned') do |json|
        json.deep_merge(
          'review_status' => 'returned_to_provider',
          'return_details' => {
            'reason' => 'split_case',
            'details' => 'Offence 1 reason requires more detail'
          }
        )
      end.to_json
    end

    before do
      stub_request(:get, "http://datastore-webmock/api/v1/applications/#{returned_application_fixture_id}")
        .to_return(body: app_split_case)

      get completed_crime_application_path(returned_application_fixture_id)
    end

    # rubocop:disable Layout/LineLength
    it 'has a notification banner with the return details' do
      assert_select 'strong.govuk-tag.govuk-tag--blue', 'Returned'

      assert_select 'div.govuk-notification-banner' do
        assert_select 'h2', 'Important'
        assert_select 'div.govuk-notification-banner__content' do
          assert_select 'h3', 'You need to tell us why your client should get legal aid.'
          assert_select 'p.govuk-body', 'We’ve returned your application because you need to add justification for all offences. This is because the case has been ’split’.'
          assert_select 'p.govuk-body', 'A case is split into more than one when the Crown Prosecution Service decides offences are not related enough to be tried at the same time.'
          assert_select 'p.govuk-body', 'The caseworker who returned this application says: Offence 1 reason requires more detail'
          assert_select 'button.govuk-button', count: 1, text: 'Add justification'
        end
      end
    end
    # rubocop:enable Layout/LineLength
  end

  describe 'show an application representation order (in `returned` status)' do
    # NOTE: this is almost identical to `submitted` state, only difference
    # is there is a notification banner with the return details and CTA button.
    # No need to test everything again.

    before do
      stub_request(:get, "http://datastore-webmock/api/v1/applications/#{returned_application_fixture_id}")
        .to_return(body: returned_application_fixture)

      get completed_crime_application_path(returned_application_fixture_id)
    end

    it 'renders the representation order page' do
      expect(response).to have_http_status(:success)

      assert_select 'h2', 'Application for a criminal legal aid representation order'
    end

    it 'does not have a button to "Upload supporting evidence"' do
      assert_select 'button.govuk-button', count: 0, text: 'Upload supporting evidence'
    end

    # rubocop:disable Layout/LineLength
    it 'has a notification banner with the return details' do
      assert_select 'div.govuk-notification-banner' do
        assert_select 'h2', 'Important'
        assert_select 'div.govuk-notification-banner__content' do
          assert_select 'h3', 'We have returned this application because we need further clarification.'
          assert_select 'p.govuk-body', 'The caseworker who returned this application says: Further information regarding IoJ required'
          assert_select 'button.govuk-button', count: 1, text: 'Update application'
        end
      end
    end
    # rubocop:enable Layout/LineLength

    it 're-creates the application and renders the check your answers page' do
      expect do
        put recreate_completed_crime_application_path(returned_application_fixture_id)
      end.to change(CrimeApplication, :count).by(1)

      expect(response).to have_http_status(:redirect)
      follow_redirect!

      # Basic smoke test, no need to test everything,
      # as that's done as unit tests already
      assert_select 'h1', 'Review the application'

      assert_select 'dl.govuk-summary-list:nth-of-type(1)' do
        assert_select 'div.govuk-summary-list__row.govuk-summary-list__row:nth-of-type(2)' do
          assert_select 'dt:nth-of-type(1)', 'LAA reference number'
          assert_select 'dd:nth-of-type(1)', '6000002'
        end

        assert_select 'div.govuk-summary-list__row.govuk-summary-list__row:nth-of-type(3)' do
          assert_select 'dt:nth-of-type(1)', 'Means tested application'
          assert_select 'dd:nth-of-type(1)', 'Yes'
        end
      end
    end
  end

  describe 'edit an in progress application (aka task list)' do
    before :all do
      # sets up a test record
      app = CrimeApplication.create(
        date_stamp: DateTime.new(2023, 4, 20, 23, 15), # date is past March daylight saving change
        office_code: '1A123B'
      )

      # needs a proper case type so it shows the interim date stamp
      Case.create(crime_application: app, case_type: CaseType::SUMMARY_ONLY.to_s)

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
        assert_select 'p:nth-of-type(1)', /[[:digit:]]/

        assert_select 'h3:nth-of-type(2)', 'First name'
        assert_select 'p:nth-of-type(2)', 'Jane'

        assert_select 'h3:nth-of-type(3)', 'Last name'
        assert_select 'p:nth-of-type(3)', 'Doe'

        assert_select 'h3:nth-of-type(4)', 'Date of birth'
        assert_select 'p:nth-of-type(4)', '1 February 1990'

        assert_select 'h3:nth-of-type(5)', 'Date stamp'
        assert_select 'p:nth-of-type(5)', '21 April 2023 12:15am'
      end
    end

    context 'when the in progress application\'s office code differs from the one selected' do
      let(:selected_office_code) { 'AN0THR' }

      it 'redirects to page not found' do
        expect(response).to redirect_to(application_not_found_errors_path)
      end
    end
  end

  describe 'deleting in progress applications' do
    before :all do
      # sets up a few test records
      app = CrimeApplication.create(office_code: '1A123B')

      Applicant.create(crime_application: app, first_name: 'Jane', last_name: 'Doe')
    end

    after :all do
      CrimeApplication.destroy_all
    end

    before do
      allow_any_instance_of(
        Datastore::ApplicationCounters
      ).to receive_messages(returned_count: 5)
    end

    it 'allows a user to check before deleting an application' do
      applicant = Applicant.find_by(first_name: 'Jane')
      app = applicant.crime_application

      get confirm_destroy_crime_application_path(app)

      expect(response.body).to include('Confirm you want to delete this application')
      expect(response.body).to include('Delete application')
      expect(response.body).to include('Back to your applications')
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
        assert_select 'p', 'Jane Doe’s in progress application has been deleted'
      end
    end
  end
end
