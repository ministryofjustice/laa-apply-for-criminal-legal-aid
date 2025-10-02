require 'rails_helper'

RSpec.describe 'Employments summary page', :authorized do
  include_context 'with office code selected'

  let(:crime_application) do
    CrimeApplication.create!(
      office_code: office_code,
      income: Income.new(employment_status: ['employed']),
      applicant: Applicant.new
    )
  end

  let!(:employment) { crime_application.employments.create!(ownership_type: 'applicant') }

  before do
    allow(MeansStatus).to receive(:full_means_required?).and_return('true')
  end

  describe 'list of added employments in summary page' do
    before do
      get edit_steps_income_client_employments_summary_path(id: crime_application)
    end

    it 'lists the employments with their details and action links' do
      expect(response).to have_http_status(:success)
      assert_select '.govuk-summary-card'
      assert_select 'h1', 'You have added 1 job'

      # confirm action are shown
      # TODO: understand which this spec is failing:
      # assert_select 'li.govuk-summary-card__action', count: 2
    end
  end

  describe 'delete an employment' do
    before do
      get confirm_destroy_steps_income_client_employments_path(id: crime_application, employment_id: employment)
    end

    it 'allows a user to confirm before deleting a employment' do
      assert_select '.govuk-summary-card'
      # confirm action are not shown
      assert_select 'li.govuk-summary-card__action', count: 0

      expect(response.body).to include('Are you sure you want to remove this job?')
      expect(response.body).to include('Yes, remove it')
      expect(response.body).to include('No, do not remove it')
    end

    context 'when there are other employments' do
      it 'deletes the employment and redirects back to the summary page' do
        employment_1 = crime_application.client_employments.create!

        expect do
          delete steps_income_client_employments_path(id: crime_application, employment_id: employment_1)
        end.to change(Employment, :count).by(-1)

        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(edit_steps_income_client_employments_summary_path(crime_application))

        follow_redirect!

        assert_select 'div.govuk-notification-banner--success', 1 do
          assert_select 'h2', 'Success'
          assert_select 'p', 'You removed the job'
        end
      end
    end

    context 'when there are no more employments' do
      it 'deletes the employment and redirects to the employment status page' do
        expect do
          delete steps_income_client_employments_path(id: crime_application, employment_id: employment)
        end.to change(Employment, :count).by(-1)

        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(edit_steps_income_employment_status_path)
      end
    end
  end
end
