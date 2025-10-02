require 'rails_helper'

RSpec.describe Steps::Income::BusinessTypeController, type: :controller do
  include_context 'current provider with active office'

  let(:existing_case) do
    CrimeApplication.create!(
      office_code: office_code,
      partner: Partner.new,
      applicant: Applicant.new,
      businesses: businesses
    )
  end

  let(:businesses) do
    [Business.new(business_type: 'partnership', ownership_type: existing_ownership)]
  end

  let(:subject_param) { 'client' }
  let(:existing_ownership) { 'applicant' }
  let(:include_partner?) { true }

  before do
    allow(MeansStatus).to receive(:include_partner?) { include_partner? }
  end

  describe '#edit' do
    context 'when application is not found' do
      it 'redirects to the application not found error page' do
        get :edit, params: { id: '12345', subject: 'partner' }
        expect(response).to redirect_to(application_not_found_errors_path)
      end
    end

    context 'when application is found' do
      before do
        get :edit, params: { id: existing_case, subject: subject_param }
      end

      context 'when subject is neither partner or client' do
        let(:subject_param) { 'co-defendant' }

        context 'when partner is included in means assessment' do
          it 'redirects to not found' do
            expect(response).to redirect_to(not_found_errors_path)
          end
        end
      end

      context 'when subject is partner' do
        let(:subject_param) { 'partner' }

        it 'succeeds' do
          expect(response).to be_successful
        end

        context 'when partner is not included in means assessment' do
          let(:include_partner?) { false }

          it 'redirects to not found' do
            expect(response).to redirect_to(not_found_errors_path)
          end
        end
      end

      context 'when subject is client' do
        let(:subject_param) { 'client' }
        let(:existing_ownership) { 'partner' }

        it 'succeeds' do
          expect(response).to be_successful
        end
      end
    end
  end

  describe '#update' do
    let(:expected_params) do
      { id: existing_case, subject: subject_param, steps_income_business_type_form: {} }
    end

    context 'when an application in progress is found' do
      let(:form_object) do
        instance_double(Steps::Income::BusinessTypeForm, attributes: { business_type: 'partnership' })
      end

      before do
        allow(Steps::Income::BusinessTypeForm).to receive(:new).and_return(form_object)
      end

      context 'when the form saves successfully' do
        before do
          expect(form_object).to receive(:save).and_return(true)
        end

        let(:decision_tree) {
          instance_double(Decisions::SelfEmployedIncomeDecisionTree, destination: '/expected_destination')
        }

        it 'asks the decision tree for the next destination and redirects there' do
          expect(Decisions::SelfEmployedIncomeDecisionTree).to receive(:new)
            .and_return(decision_tree)

          put :update, params: expected_params

          expect(response).to redirect_to('/expected_destination')
        end
      end

      context 'when the form fails to save' do
        before do
          expect(form_object).to receive(:save).and_return(false)
        end

        it 'renders the question page again' do
          put :update, params: expected_params

          expect(response).to have_http_status(:ok)
        end
      end
    end
  end
end
