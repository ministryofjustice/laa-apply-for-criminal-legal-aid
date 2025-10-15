require 'rails_helper'

RSpec.describe Steps::Case::OtherChargeController, type: :controller do
  include_context 'current provider with active office'

  let(:existing_case) do
    CrimeApplication.create!(
      office_code: office_code,
      applicant: Applicant.new,
      partner: Partner.new,
      partner_detail: PartnerDetail.new(involvement_in_case: 'codefendant', conflict_of_interest: 'no')
    )
  end

  let(:kase) do
    Case.create(
      crime_application: existing_case,
      case_type: CaseType::EITHER_WAY,
      client_other_charge_in_progress: 'yes',
      partner_other_charge_in_progress: 'yes',
    )
  end

  let(:ownership_type) { nil }
  let(:subject_param) { 'client' }

  describe '#edit' do
    context 'when application is not found' do
      it 'redirects to the application not found error page' do
        get :edit, params: { id: '12345', subject: subject_param }
        expect(response).to redirect_to(application_not_found_errors_path)
      end
    end

    context 'when application is found' do
      before do
        OtherCharge.create(case: kase, ownership_type: ownership_type)
        get :edit, params: { id: existing_case, subject: subject_param }
      end

      context 'when subject is client' do
        let(:subject_param) { 'client' }
        let(:ownership_type) { 'applicant' }

        it 'succeeds' do
          expect(response).to be_successful
        end
      end

      context 'when subject is partner' do
        let(:subject_param) { 'partner' }
        let(:ownership_type) { 'partner' }

        it 'succeeds' do
          expect(response).to be_successful
        end
      end
    end
  end

  describe '#update' do
    let(:form_object) { instance_double(Steps::Case::OtherChargeForm, attributes: { foo: double }) }
    let(:form_class_params_name) { form_class.name.underscore }
    let(:expected_params) { { id: existing_case, subject: subject_param, form_class_params_name: { foo: 'bar' } } }

    context 'when application is not found' do
      let(:existing_case) { '12345' }

      it 'redirects to the application not found error page' do
        put :update, params: expected_params
        expect(response).to redirect_to(application_not_found_errors_path)
      end
    end

    context 'when an application in progress is found' do
      before do
        allow(Steps::Case::OtherChargeForm).to receive(:new).and_return(form_object)
        OtherCharge.create(case: kase, ownership_type: ownership_type)
      end

      let(:subject_param) { 'client' }
      let(:ownership_type) { 'applicant' }

      context 'when the form saves successfully' do
        before do
          expect(form_object).to receive(:save).and_return(true)
        end

        let(:decision_tree) { instance_double(Decisions::CaseDecisionTree, destination: '/expected_destination') }

        it 'asks the decision tree for the next destination and redirects there' do
          expect(Decisions::CaseDecisionTree).to receive(:new).and_return(decision_tree)
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
          put :update, params: expected_params
          expect(response).to have_http_status(:ok)
        end
      end
    end
  end
end
