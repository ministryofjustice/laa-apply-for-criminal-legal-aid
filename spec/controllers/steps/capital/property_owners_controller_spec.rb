require 'rails_helper'

RSpec.describe Steps::Capital::PropertyOwnersController, type: :controller do
  let(:form_class) { Steps::Capital::PropertyOwnerForm }
  let(:decision_tree_class) { Decisions::CapitalDecisionTree }
  let(:crime_application) { CrimeApplication.create }
  let(:property) do
    Property.create!(property_type: PropertyType::RESIDENTIAL, crime_application: crime_application)
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
        steps_capital_property_owner_form: { property_owners_attributes: }
      }
    end

    context 'when valid property owners attributes' do
      let(:property_owners_attributes) do
        { '0' => { name: 'name 1', relationship: 'friends', percentage_owned: 10 } }
      end

      it 'redirects to the which_savings path' do
        put :update, params: expected_params, session: { crime_application_id: crime_application.id }
        expect(response).to redirect_to(/which_savings_does_client_have/)
      end
    end

    context 'when invalid property owners attributes' do
      let(:property_owners_attributes) do
        { '0' => { name: nil, relationship: 'friends', percentage_owned: 10 } }
      end

      it 'not redirects to the which_savings path' do
        put :update, params: expected_params, session: { crime_application_id: crime_application.id }
        expect(response).not_to redirect_to(/which_savings_does_client_have/)
      end
    end
  end
end
