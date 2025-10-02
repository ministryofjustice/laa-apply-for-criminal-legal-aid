require 'rails_helper'

RSpec.describe Steps::Income::DependantsController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::Income::DependantsForm, Decisions::IncomeDecisionTree do
    describe 'CRUD actions' do
      let(:crime_application) { CrimeApplication.create(office_code:) }

      context 'adding a new dependant' do
        it 'has the expected step name' do
          expect(subject).to receive(:update_and_advance).with(
            Steps::Income::DependantsForm, as: :add_dependant, flash: nil
          )

          put :update, params: { id: crime_application, add_dependant: '' }
        end
      end

      context 'deleting a dependant' do
        let(:form_class_params_name) { Steps::Income::DependantsForm.name.underscore }
        let(:dependants_attributes) do
          {
            dependants_attributes: {
              '0' => { age: '12', _destroy: '1', id: '12345' }
            }
          }
        end

        it 'has the expected step name' do
          expect(subject).to receive(:update_and_advance).with(
            Steps::Income::DependantsForm, as: :delete_dependant,
            flash: { success: 'The dependant has been deleted' }
          )

          put :update, params: { :id => crime_application, form_class_params_name => dependants_attributes }
        end
      end

      context 'finishing dependants' do
        it 'has the expected step name' do
          expect(subject).to receive(:update_and_advance).with(
            Steps::Income::DependantsForm, as: :dependants_finished, flash: nil
          )

          put :update, params: { id: crime_application }
        end
      end
    end
  end
end
