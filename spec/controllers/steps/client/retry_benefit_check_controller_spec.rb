require 'rails_helper'

RSpec.describe Steps::Client::RetryBenefitCheckController, type: :controller do
  it_behaves_like 'a no-op advance step controller', :retry_benefit_check, Decisions::ClientDecisionTree

  describe '#update' do
    context 'when the user chooses to apply eforms' do
      let(:existing_case) { CrimeApplication.create(applicant: Applicant.new) }

      it 'redirects to the eforms site' do
        put :update, params: { id: existing_case, commit_draft: '' }
        expect(response).to redirect_to(Settings.eforms_url)
      end
    end
  end
end
