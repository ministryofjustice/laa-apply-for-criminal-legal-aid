require 'rails_helper'

RSpec.describe Steps::Income::Client::EmploymentsSummaryController, type: :controller do
  let(:existing_case) do
    CrimeApplication.create(employments: employments, applicant: Applicant.new)
  end

  context 'when employments present' do
    let(:employments) { [Employment.new] }

    it_behaves_like 'a generic step controller',
                    Steps::Income::Client::EmploymentsSummaryForm, Decisions::IncomeDecisionTree
  end

  context 'when employments empty' do
    let(:employments) { [] }

    describe '#edit' do
      it 'redirects to the employments type page' do
        get :edit, params: { id: existing_case }

        expect(response).to redirect_to(edit_steps_income_employment_status_path(existing_case))
      end
    end
  end
end
