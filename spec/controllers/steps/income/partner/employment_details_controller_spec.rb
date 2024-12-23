require 'rails_helper'

RSpec.describe Steps::Income::Partner::EmploymentDetailsController, type: :controller do
  let(:form_class) { Steps::Income::Partner::EmploymentDetailsForm }
  let(:decision_tree_class) { Decisions::IncomeDecisionTree }
  let(:crime_application) { CrimeApplication.create }
  let(:employment) do
    Employment.create!(crime_application: crime_application, ownership_type: OwnershipType::PARTNER.to_s)
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
        Employment.create!(crime_application: CrimeApplication.create!, ownership_type: OwnershipType::PARTNER.to_s)
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
        steps_income_partner_employment_details_form: {
          job_title: 'manager',
          amount: 600,
          frequency: 'four_weeks',
          before_or_after_tax: BeforeOrAfterTax::AFTER,
        }
      }
    end

    context 'when invalid address attributes' do
      before { expected_params[:steps_income_partner_employment_details_form].merge!(amount: nil, frequency: nil) }

      it 'does not redirect to the `employments_summary` path' do
        put :update, params: expected_params, session: { crime_application_id: crime_application.id }
        expect(response).not_to redirect_to edit_steps_income_partner_deductions_from_pay_path
      end
    end
  end
end
