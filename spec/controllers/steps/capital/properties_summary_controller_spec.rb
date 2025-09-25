require 'rails_helper'

RSpec.describe Steps::Capital::PropertiesSummaryController, type: :controller do
  include_context 'current provider with active office'
  let(:existing_case) do
    CrimeApplication.create(properties: properties, applicant: Applicant.new, office_code: office_code)
  end

  context 'when properties present' do
    let(:properties) { [Property.new(property_type: 'land')] }

    it_behaves_like 'a generic step controller',
                    Steps::Capital::PropertiesSummaryForm, Decisions::CapitalDecisionTree
  end

  context 'when properties empty' do
    let(:properties) { [] }

    describe '#edit' do
      it 'redirects to the properties type page' do
        get :edit, params: { id: existing_case }

        expect(response).to redirect_to(
          edit_steps_capital_property_type_path(existing_case)
        )
      end
    end
  end
end
