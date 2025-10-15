require 'rails_helper'

RSpec.describe Steps::Capital::SavingsSummaryController, type: :controller do
  include_context 'current provider with active office'

  let(:existing_case) do
    CrimeApplication.create(office_code: office_code, capital: Capital.new, savings: savings, applicant: Applicant.new)
  end

  before do
    allow_any_instance_of(Capital).to receive(:savings).and_return(savings)
  end

  context 'when savings present' do
    let(:savings) { [Saving.new(saving_type: 'bank', ownership_type: 'applicant')] }

    it_behaves_like 'a generic step controller',
                    Steps::Capital::SavingsSummaryForm, Decisions::CapitalDecisionTree
  end

  context 'when savings empty' do
    let(:savings) { [] }

    describe '#edit' do
      it 'redirects to the savings type page' do
        get :edit, params: { id: existing_case }

        expect(response).to redirect_to(
          edit_steps_capital_saving_type_path(existing_case)
        )
      end
    end
  end
end
