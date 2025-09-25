require 'rails_helper'

RSpec.describe 'DWP passporting sub journey', :authorized do
  include_context 'with office code selected'

  describe 'confirm applicant personal details page' do
    let(:crime_application) { CrimeApplication.first }

    before do
      # sets up a few test records
      app = CrimeApplication.create(office_code:)

      Applicant.create(
        crime_application: app,
        first_name: 'Jane', last_name: 'Doe',
        date_of_birth: Date.new(1990, 2, 1),
        has_nino: 'yes',
        nino: 'AB123456A'
      )

      get edit_steps_dwp_confirm_details_path(crime_application)
    end

    # rubocop:disable RSpec/ExampleLength
    it 'has a read only version of the client details summary' do
      expect(response).to have_http_status(:success)

      assert_select 'h1', 'Check your client’s details'
      assert_select 'h2.govuk-heading-m', { text: 'Client details', count: 0 } # the summary is headless

      assert_select 'dl.govuk-summary-list' do
        assert_select 'div.govuk-summary-list__row.govuk-summary-list__row--no-actions:nth-of-type(1)' do
          assert_select 'dt', 'First name'
          assert_select 'dd', 'Jane'
        end

        assert_select 'div.govuk-summary-list__row.govuk-summary-list__row--no-actions:nth-of-type(2)' do
          assert_select 'dt', 'Last name'
          assert_select 'dd', 'Doe'
        end

        assert_select 'div.govuk-summary-list__row.govuk-summary-list__row--no-actions:nth-of-type(3)' do
          assert_select 'dt', 'Other names'
          assert_select 'dd', 'None'
        end

        assert_select 'div.govuk-summary-list__row.govuk-summary-list__row--no-actions:nth-of-type(4)' do
          assert_select 'dt', 'Date of birth'
          assert_select 'dd', '1 February 1990'
        end

        assert_select 'div.govuk-summary-list__row.govuk-summary-list__row--no-actions:nth-of-type(5)' do
          assert_select 'dt', 'National Insurance number'
          assert_select 'dd', 'AB123456A'
        end
      end
    end
    # rubocop:enable RSpec/ExampleLength
  end
end
