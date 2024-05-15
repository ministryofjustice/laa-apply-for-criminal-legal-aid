require 'rails_helper'

RSpec.describe Steps::Income::Client::EmploymentDetailsController, type: :controller do
  let(:form_class) { Steps::Income::Client::EmploymentDetailsForm }
  let(:decision_tree_class) { Decisions::IncomeDecisionTree }
  let(:crime_application) { CrimeApplication.create }
  let(:employment) do
    Employment.create!(crime_application:)
  end

  describe '#edit' do
    context 'when employment is not found' do
      it 'redirects to the employment not found error page' do
        get :edit, params: { id: '12345', employment_id: '123' }
        expect(response).to redirect_to(application_not_found_errors_path)
      end
    end

    context 'when employment is found' do
      it 'responds with HTTP success' do
        get :edit, params: { id: crime_application, employment_id: employment }
        expect(response).to be_successful
      end
    end

    context 'when employment is for another application' do
      let(:employment) do
        Employment.create!(crime_application: CrimeApplication.create!)
      end

      it 'responds with HTTP success' do
        get :edit, params: { id: crime_application, employment_id: employment }

        expect(response).to redirect_to(not_found_errors_path)
      end
    end
  end

  describe '#update' do
    let(:expected_params) do
      {
        id: crime_application,
        employment_id: employment,
        steps_income_client_employment_details_form: { job_title: 'manager', income_payment_attributes: income_payment_attributes }
      }
    end

    let(:income_payment_attributes) do
      {
        amount: 600,
        frequency: 'four_weeks',
        before_or_after_tax: BeforeOrAfterTax::AFTER.to_s,
      }
    end

    context 'when valid income_payment attributes' do
      it 'redirects to `employed_exit` page' do
        put :update, params: expected_params, session: { crime_application_id: crime_application.id }
        expect(response).to redirect_to steps_income_employed_exit_path
      end
    end

    context 'when invalid address attributes' do
      before { income_payment_attributes.merge!(amount: nil, frequency: nil) }

      it 'does not redirect to the `properties_summary` path' do
        put :update, params: expected_params, session: { crime_application_id: crime_application.id }
        expect(response).not_to redirect_to steps_income_employed_exit_path
      end
    end
  end
end
