require 'rails_helper'

RSpec.describe Steps::Income::Client::EmploymentsSummaryController, type: :controller do
  include_context 'current provider with active office'

  let(:existing_case) do
    CrimeApplication.create(office_code: office_code, client_employments: client_employments, applicant: Applicant.new)
  end

  context 'when client_employments present' do
    let(:client_employments) { [Employment.new(ownership_type: OwnershipType::APPLICANT.to_s)] }

    it_behaves_like 'a generic step controller',
                    Steps::Income::Client::EmploymentsSummaryForm, Decisions::IncomeDecisionTree
  end

  context 'when client_employments empty' do
    let(:client_employments) { [] }

    describe '#edit' do
      it 'redirects to the `employment_status` page' do
        get :edit, params: { id: existing_case }

        expect(response).to redirect_to(edit_steps_income_employment_status_path(existing_case))
      end
    end
  end
end
