require 'rails_helper'

RSpec.describe Steps::Capital::NationalSavingsCertificatesController, type: :controller do
  include_context 'current provider with active office'

  let(:form_class) { Steps::Capital::NationalSavingsCertificatesForm }
  let(:decision_tree_class) { Decisions::CapitalDecisionTree }

  let(:crime_application) do
    CrimeApplication.create!(
      office_code: office_code,
      partner: Partner.new,
      partner_detail: PartnerDetail.new(involvement_in_case: 'none'),
      applicant: Applicant.new
    )
  end

  describe '#edit' do
    context 'when application is not found' do
      it 'redirects to the application not found error page' do
        get :edit, params: { id: '12345', national_savings_certificate_id: '123' }
        expect(response).to redirect_to(application_not_found_errors_path)
      end
    end

    context 'when application is found' do
      let(:national_savings_certificate) do
        NationalSavingsCertificate.create!(crime_application: crime_application, ownership_type: 'applicant')
      end

      it 'responds with HTTP success' do
        get :edit, params: { id: crime_application, national_savings_certificate_id: national_savings_certificate }
        expect(response).to be_successful
      end
    end

    context 'when National Savings Certificate is for another application' do
      let(:national_savings_certificate) do
        NationalSavingsCertificate.create!(
          crime_application: CrimeApplication.create!(office_code:),
          ownership_type: 'applicant'
        )
      end

      it 'responds with HTTP success' do
        get :edit, params: { id: crime_application, national_savings_certificate_id: national_savings_certificate }

        expect(response).to redirect_to(not_found_errors_path)
      end
    end
  end

  describe '#update' do
    let(:form_object) { instance_double(form_class, attributes: { foo: double }) }
    let(:form_class_params_name) { form_class.name.underscore }

    let(:expected_params) do
      {
        :id => crime_application,
        :national_savings_certificate_id => national_savings_certificate,
        form_class_params_name => { foo: 'bar' }
      }
    end

    context 'when application is not found' do
      let(:crime_application) { '12345' }
      let(:national_savings_certificate) { '123' }

      it 'redirects to the application not found error page' do
        put :update, params: expected_params
        expect(response).to redirect_to(application_not_found_errors_path)
      end
    end

    context 'when National Savings Certificate is for another application' do
      let(:national_savings_certificate) do
        NationalSavingsCertificate.create!(crime_application: CrimeApplication.create!(office_code:),
                                           ownership_type: 'applicant')
      end

      it 'responds with HTTP success' do
        put :update, params: expected_params

        expect(response).to redirect_to(not_found_errors_path)
      end
    end

    context 'when an in progress application and National Savings Certificate is found' do
      let(:national_savings_certificate) do
        NationalSavingsCertificate.create!(crime_application: crime_application, ownership_type: 'applicant')
      end

      before do
        national_savings_certificate
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
          put :update, params: expected_params, session: { crime_application_id: crime_application.id }
          expect(response).to have_http_status(:ok)
        end
      end
    end
  end
end
