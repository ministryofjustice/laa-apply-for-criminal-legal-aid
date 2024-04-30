require 'rails_helper'

RSpec.describe Steps::Capital::HasNationalSavingsCertificatesController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Capital::HasNationalSavingsCertificatesForm,
                  Decisions::CapitalDecisionTree do
    context 'when National Saving Certificates present' do
      let(:existing_case) do
        CrimeApplication.create(national_savings_certificates: [NationalSavingsCertificate.new],
                                applicant: Applicant.new)
      end

      describe '#edit' do
        it 'redirects to the national_saving_certificates summary page' do
          get :edit, params: { id: existing_case }

          expect(response).to redirect_to(
            edit_steps_capital_national_savings_certificates_summary_path(existing_case)
          )
        end
      end
    end
  end
end
