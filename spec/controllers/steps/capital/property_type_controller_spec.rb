require 'rails_helper'

RSpec.describe Steps::Capital::PropertyTypeController, type: :controller do
  it_behaves_like('a generic step controller', Steps::Capital::PropertyTypeForm, Decisions::CapitalDecisionTree) do
    context 'when properties present' do
      let(:existing_case) do
        CrimeApplication.create(office_code: office_code, properties: [Property.new(property_type: :bank)],
                                applicant: Applicant.new)
      end

      describe '#edit' do
        it 'redirects to the properties summary page' do
          get :edit, params: { id: existing_case }

          expect(response).to redirect_to(
            edit_steps_capital_properties_summary_path(existing_case)
          )
        end
      end
    end
  end
end
