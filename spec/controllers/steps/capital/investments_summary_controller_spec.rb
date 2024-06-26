require 'rails_helper'

RSpec.describe Steps::Capital::InvestmentsSummaryController, type: :controller do
  let(:existing_case) do
    CrimeApplication.create(investments: investments, applicant: Applicant.new)
  end

  context 'when investments present' do
    let(:investments) { [Investment.new(investment_type: 'pep', ownership_type: 'applicant')] }

    it_behaves_like 'a generic step controller',
                    Steps::Capital::InvestmentsSummaryForm, Decisions::CapitalDecisionTree
  end

  context 'when investments empty' do
    let(:investments) { [] }

    describe '#edit' do
      it 'redirects to the investments type page' do
        get :edit, params: { id: existing_case }

        expect(response).to redirect_to(
          edit_steps_capital_investment_type_path(existing_case)
        )
      end
    end
  end
end
