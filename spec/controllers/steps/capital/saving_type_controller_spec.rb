require 'rails_helper'

RSpec.describe Steps::Capital::SavingTypeController, type: :controller do
  include_context 'current provider with active office'

  let(:savings) { [] }
  let(:capital) { Capital.new }

  let(:existing_case) do
    CrimeApplication.create(office_code: office_code, capital: capital, savings: savings, applicant: Applicant.new)
  end

  before do
    allow_any_instance_of(Capital).to receive(:savings).and_return(savings)
  end

  it_behaves_like 'a generic step controller',
                  Steps::Capital::SavingTypeForm, Decisions::CapitalDecisionTree do
    context 'when savings present' do
      let(:savings) { [Saving.new(saving_type: :bank, ownership_type: 'applicant')] }

      describe '#edit' do
        it 'redirects to the savings summary page' do
          get :edit, params: { id: existing_case }

          expect(response).to redirect_to(edit_steps_capital_savings_summary_path(existing_case))
        end
      end
    end
  end
end
