require 'rails_helper'

RSpec.describe Steps::Income::Client::EmployerDetailsController, type: :controller do
  include_context 'current provider with active office'
  let(:form_class) { Steps::Income::Client::EmployerDetailsForm }
  let(:decision_tree_class) { Decisions::IncomeDecisionTree }
  let(:crime_application) { CrimeApplication.create(office_code:) }
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
        Employment.create!(crime_application: CrimeApplication.create!(office_code:))
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
        steps_income_client_employer_details_form: { employer_name: 'abc', address: address_attributes }
      }
    end

    let(:address_attributes) do
      {
        address_line_one: 'address_line_one',
        address_line_two: 'address_line_two',
        city: 'city',
        country: 'country',
        postcode: 'postcode'
      }
    end

    context 'when valid address attributes' do
      it 'redirects to `employment_details` page' do
        put :update, params: expected_params, session: { crime_application_id: crime_application.id }
        expect(response).to redirect_to edit_steps_income_client_employment_details_path
      end
    end

    context 'when invalid address attributes' do
      before { address_attributes.merge!(address_line_one: nil, city: nil) }

      it 'does not redirect to the `employment_details` path' do
        put :update, params: expected_params, session: { crime_application_id: crime_application.id }
        expect(response).not_to redirect_to edit_steps_income_client_employment_details_path
      end
    end
  end
end
