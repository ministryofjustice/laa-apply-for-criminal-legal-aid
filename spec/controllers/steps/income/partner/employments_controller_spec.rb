require 'rails_helper'

RSpec.describe Steps::Income::Partner::EmploymentsController, type: :controller do
  let(:form_class) { Steps::Income::Partner::EmploymentDetailsForm }
  let(:decision_tree_class) { Decisions::IncomeDecisionTree }

  let(:crime_application) { CrimeApplication.create }

  describe '#destroy' do
    let(:form_object) { instance_double(form_class, attributes: { foo: double }) }
    let(:form_class_params_name) { form_class.name.underscore }

    let(:expected_params) do
      {
        :id => crime_application,
        :employment_id => employment,
        form_class_params_name => { foo: 'bar' }
      }
    end

    context 'when deleting an employment' do
      let(:employment) do
        Employment.create!(crime_application: crime_application, ownership_type: OwnershipType::PARTNER.to_s)
      end

      describe 'confirm destroy' do
        it 'renders the employment page again' do
          get :confirm_destroy, params: expected_params, session: { crime_application_id: crime_application.id }
          expect(response).not_to have_http_status(:redirect)
        end
      end

      context 'when deleting an employment' do
        context 'when employment is the last remaining employment' do
          it 'renders the employment status page again' do
            delete :destroy, params: expected_params, session: { crime_application_id: crime_application.id }
            expect(Employment.count).to be 0
            expect(response).to redirect_to(%r{/steps/income/what-is-the-partners-employment-status})
          end
        end

        context 'when employment is not the last remaining employment' do
          before do
            Employment.create!(crime_application: crime_application, ownership_type: OwnershipType::PARTNER.to_s)
          end

          it 'redirects to `employments_summary` page' do
            delete :destroy, params: expected_params, session: { crime_application_id: crime_application.id }
            expect(Employment.count).to be 1
            expect(response).to redirect_to edit_steps_income_partner_employments_summary_path
          end
        end
      end
    end
  end
end
