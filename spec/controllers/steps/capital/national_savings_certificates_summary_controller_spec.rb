require 'rails_helper'

RSpec.describe Steps::Capital::NationalSavingsCertificatesSummaryController, type: :controller do
  let(:existing_case) do
    CrimeApplication.create(capital: Capital.new, national_savings_certificates: national_savings_certificates,
                            applicant: Applicant.new)
  end

  before do
    allow_any_instance_of(Capital).to receive(:national_savings_certificates).and_return(national_savings_certificates)
  end

  context 'when national savings certificates present' do
    let(:national_savings_certificates) {
      [NationalSavingsCertificate.new(ownership_type: 'applicant')]
    }

    it_behaves_like 'a generic step controller',
                    Steps::Capital::NationalSavingsCertificatesSummaryForm, Decisions::CapitalDecisionTree
  end

  context 'when national savings certificates empty' do
    let(:national_savings_certificates) { [] }

    describe '#edit' do
      it 'redirects to the national savings certificates type page' do
        get :edit, params: { id: existing_case }

        expect(response).to redirect_to(
          edit_steps_capital_has_national_savings_certificates_path(existing_case)
        )
      end
    end
  end
end
