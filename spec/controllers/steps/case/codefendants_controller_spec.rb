require 'rails_helper'

RSpec.describe Steps::Case::CodefendantsController, type: :controller do
  include_context 'current provider with active office'
  it_behaves_like 'a generic step controller', Steps::Case::CodefendantsForm, Decisions::CaseDecisionTree do
    describe 'additional CRUD actions' do
      let(:existing_case) { CrimeApplication.create(office_code:) }

      context 'adding a new codefendant' do
        it 'has the expected step name' do
          expect(
            subject
          ).to receive(:update_and_advance).with(
            Steps::Case::CodefendantsForm, as: :add_codefendant, flash: nil
          )

          put :update, params: { id: existing_case, add_codefendant: '' }
        end
      end

      context 'deleting a codefendant' do
        let(:form_class_params_name) { Steps::Case::CodefendantsForm.name.underscore }
        let(:codefendant_attributes) do
          {
            codefendants_attributes: {
              '0' => { first_name: 'John', last_name: 'Doe', _destroy: '1', id: '12345' }
            }
          }
        end

        it 'has the expected step name' do
          expect(
            subject
          ).to receive(:update_and_advance).with(
            Steps::Case::CodefendantsForm, as: :delete_codefendant,
            flash: { success: 'The co-defendant has been deleted' }
          )

          put :update, params: { :id => existing_case, form_class_params_name => codefendant_attributes }
        end
      end

      context 'finishing codefendants' do
        it 'has the expected step name' do
          expect(
            subject
          ).to receive(:update_and_advance).with(
            Steps::Case::CodefendantsForm, as: :codefendants_finished, flash: nil
          )

          put :update, params: { id: existing_case, foo: { bar: '1' } }
        end
      end
    end
  end

  it_behaves_like 'a step disallowed for change in financial circumstances applications'
end
