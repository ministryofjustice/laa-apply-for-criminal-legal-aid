require 'rails_helper'

RSpec.describe Steps::Capital::SavingTypeController, type: :controller do
  it_behaves_like 'a generic step controller',
                  Steps::Capital::SavingTypeForm, Decisions::CapitalDecisionTree do
    context 'when savings present' do
      let(:existing_case) do
        CrimeApplication.create(savings: [Saving.new(saving_type: :bank)], applicant: Applicant.new)
      end

      describe '#edit' do
        it 'redirects to the savings summary page' do
          get :edit, params: { id: existing_case }

          expect(response).to redirect_to(
            edit_steps_capital_savings_summary_path(existing_case)
          )
        end
      end
    end
  end
end
