require 'rails_helper'

RSpec.describe Steps::Capital::InvestmentTypeController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Capital::InvestmentTypeForm, Decisions::CapitalDecisionTree do
    context 'when investments present' do
      let(:existing_case) do
        CrimeApplication.create(investments: [Investment.new(investment_type: :bank, ownership_type: 'applicant')],
                                applicant: Applicant.new)
      end

      describe '#edit' do
        it 'redirects to the investments summary page' do
          get :edit, params: { id: existing_case }

          expect(response).to redirect_to(
            edit_steps_capital_investments_summary_path(existing_case)
          )
        end
      end
    end
  end
end
