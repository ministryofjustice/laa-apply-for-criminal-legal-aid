require 'rails_helper'

RSpec.describe Steps::Income::Client::DeductionsController, type: :controller do
  let(:form_class) { Steps::Income::Client::DeductionsForm }
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
        employment_id: employment.id,
        steps_income_client_deductions_form: {
          income_tax:,
          national_insurance:,
          types:,
          other:
        }
      }
    end

    let(:income_tax) { { amount: '', frequency: '', employment_id: employment.id } }
    let(:national_insurance) { { amount: '', frequency: '', employment_id: employment.id } }
    let(:other) { { amount: 300, frequency: 'week', employment_id: employment.id, details: 'other deduction details' } }
    let(:types) { ['other'] }

    context 'when valid deduction attributes' do
      it 'redirects to `employed_exit` page' do
        put :update, params: expected_params, session: { crime_application_id: crime_application.id }
        expect(response).to redirect_to steps_income_employed_exit_path
        expect(employment.deductions.count).to eq(1)
        expect(employment.deductions.first).to have_attributes({ deduction_type: 'other',
                                                    amount: 300_00,
                                                    frequency: 'week',
                                                    details: 'other deduction details' })
        expect(employment.has_no_deductions).to be_nil
      end
    end

    context 'when invalid deduction attributes' do
      before { other.merge!(amount: nil, frequency: nil) }

      it 'redirects not to `employed_exit` page' do
        put :update, params: expected_params, session: { crime_application_id: crime_application.id }
        expect(response).not_to redirect_to steps_income_employed_exit_path
        expect(employment.deductions.count).to eq(0)
      end
    end
  end
end
