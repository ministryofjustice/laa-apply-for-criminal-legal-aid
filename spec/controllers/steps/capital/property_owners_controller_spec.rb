require 'rails_helper'

RSpec.describe Steps::Capital::PropertyOwnersController, type: :controller do
  include_context 'current provider with active office'

  let(:form_class) { Steps::Capital::PropertyOwnersForm }
  let(:decision_tree_class) { Decisions::CapitalDecisionTree }
  let(:crime_application) { CrimeApplication.create(office_code:) }
  let(:property) do
    Property.create!(property_type: PropertyType::RESIDENTIAL, crime_application: crime_application,
                     percentage_applicant_owned: percentage_applicant_owned)
  end
  let(:percentage_applicant_owned) { 10 }

  describe 'property owner actions' do
    let(:form_class_params_name) { form_class.name.underscore }
    let(:property_record) { Property.create(crime_application: crime_application, property_type: 'residential') }

    context 'when adding a property owner' do
      after do
        put :update, params: {
          id: crime_application.id,
          property_id: property_record.id,
          add_property_owner: ''
        }
      end

      it 'has the expected step name' do
        expect(
          subject
        ).to receive(:update_and_advance).with(
          form_class,
          record: property_record,
          as: :add_property_owner,
          flash: nil
        )
      end
    end

    context 'when deleting a property owner' do
      let(:property_owners_attributes) do
        {
          property_owners_attributes: {
            '0' => {
              'name' => 'a',
              'relationship' => 'friends',
              'other_relationship' => '',
              'percentage_owned' => '50',
              '_destroy' => '1',
              'id' => '123'
            }
          }
        }
      end

      after do
        put :update, params: {
          :id => crime_application.id,
          :property_id => property_record.id,
          form_class_params_name => property_owners_attributes
        }
      end

      it 'has the expected step name' do
        expect(
          subject
        ).to receive(:update_and_advance).with(
          form_class,
          record: property_record,
          as: :delete_property_owner,
          flash: { success: 'The owner has been deleted' }
        )
      end
    end
  end

  describe '#edit' do
    context 'when property is not found' do
      it 'redirects to the property not found error page' do
        get :edit, params: { id: '12345', property_id: '123' }
        expect(response).to redirect_to(application_not_found_errors_path)
      end
    end

    context 'when property is found' do
      it 'responds with HTTP success' do
        get :edit, params: { id: crime_application, property_id: property }
        expect(response).to be_successful
      end
    end

    context 'when property is for another application' do
      let(:property) do
        Property.create!(property_type: PropertyType::RESIDENTIAL, crime_application: CrimeApplication.create!)
      end

      it 'responds with HTTP success' do
        get :edit, params: { id: crime_application, property_id: property }

        expect(response).to redirect_to(not_found_errors_path)
      end
    end
  end

  describe '#update' do
    let(:expected_params) do
      {
        id: crime_application,
        property_id: property,
        steps_capital_property_owners_form: { property_owners_attributes: }
      }
    end

    context 'when valid property owners attributes' do
      let(:property_owners_attributes) do
        { '0' => { name: 'name 1', relationship: 'friends', percentage_owned: 90 } }
      end

      it 'redirects to the `properties_summary` path' do
        put :update, params: expected_params, session: { crime_application_id: crime_application.id }
        expect(response).to redirect_to edit_steps_capital_properties_summary_path
      end
    end

    context 'when invalid property owners attributes' do
      let(:property_owners_attributes) do
        { '0' => { name: nil, relationship: 'friends', percentage_owned: 100 } }
      end

      it 'does not redirect to the `properties_summary` path' do
        put :update, params: expected_params, session: { crime_application_id: crime_application.id }
        expect(response).not_to redirect_to edit_steps_capital_properties_summary_path
      end
    end
  end
end
