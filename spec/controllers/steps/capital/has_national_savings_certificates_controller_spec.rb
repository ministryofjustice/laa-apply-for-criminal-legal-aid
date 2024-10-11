require 'rails_helper'

RSpec.describe Steps::Capital::HasNationalSavingsCertificatesController, type: :controller do
  let(:national_savings_certificates) { [] }
  let(:capital) { Capital.new }

  let(:existing_case) do
    CrimeApplication.create(
      capital: capital,
      national_savings_certificates: national_savings_certificates,
      applicant: Applicant.new,
    )
  end

  before do
    allow_any_instance_of(Capital).to receive(:national_savings_certificates).and_return(national_savings_certificates)
  end

  it_behaves_like 'a generic step controller', Steps::Capital::HasNationalSavingsCertificatesForm,
                  Decisions::CapitalDecisionTree do
    context 'when National Saving Certificates present' do
      let(:national_savings_certificates) { [NationalSavingsCertificate.new(ownership_type: 'applicant')] }

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
