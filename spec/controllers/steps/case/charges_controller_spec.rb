require 'rails_helper'

RSpec.describe Steps::Case::ChargesController, type: :controller do
  include_context 'current provider with active office'

  let(:form_class) { Steps::Case::ChargesForm }
  let(:decision_tree_class) { Decisions::CaseDecisionTree }

  let(:crime_application) { CrimeApplication.create(office_code:) }

  describe '#edit' do
    context 'when application is not found' do
      before do
        # Needed because some specs that include these examples stub current_crime_application,
        # which is undesirable for this particular test
        allow(controller).to receive(:current_crime_application).and_return(nil)
      end

      it 'redirects to the application not found error page' do
        get :edit, params: { id: '12345', charge_id: '123' }
        expect(response).to redirect_to(application_not_found_errors_path)
      end
    end

    context 'when application is found' do
      let!(:existing_application) { CrimeApplication.create(office_code: office_code, case: Case.new) }
      let!(:existing_charge) { Charge.find_or_create_by(case: existing_application.case) }

      it 'responds with HTTP success' do
        get :edit, params: { id: existing_application, charge_id: existing_charge }
        expect(response).to be_successful
      end
    end
  end

  describe '#update' do
    let(:form_object) { instance_double(form_class, attributes: { foo: double }) }
    let(:form_class_params_name) { form_class.name.underscore }
    let(:expected_params) do
      { :id => existing_application, :charge_id => existing_charge, form_class_params_name => { foo: 'bar' } }
    end

    context 'when application is not found' do
      let(:existing_application) { '12345' }
      let(:existing_charge) { '123' }

      before do
        # Needed because some specs that include these examples stub current_crime_application,
        # which is undesirable for this particular test
        allow(controller).to receive(:current_crime_application).and_return(nil)
      end

      it 'redirects to the application not found error page' do
        put :update, params: expected_params
        expect(response).to redirect_to(application_not_found_errors_path)
      end
    end

    context 'when an application in progress is found' do
      let(:existing_application) { CrimeApplication.create(office_code: office_code, case: Case.new) }
      let(:existing_charge) { Charge.find_or_create_by(case: existing_application.case) }

      before do
        existing_application
        existing_charge
        allow(form_class).to receive(:new).and_return(form_object)
      end

      context 'when the form saves successfully' do
        before do
          expect(form_object).to receive(:save).and_return(true)
        end

        let(:decision_tree) { instance_double(decision_tree_class, destination: '/expected_destination') }

        it 'asks the decision tree for the next destination and redirects there' do
          expect(decision_tree_class).to receive(:new).and_return(decision_tree)

          put :update, params: expected_params

          expect(response).to have_http_status(:redirect)
          expect(subject).to redirect_to('/expected_destination')
        end
      end

      context 'when the form fails to save' do
        before do
          expect(form_object).to receive(:save).and_return(false)
        end

        it 'renders the question page again' do
          put :update, params: expected_params, session: { crime_application_id: existing_application.id }
          expect(response).to have_http_status(:ok)
        end
      end
    end
  end
end
