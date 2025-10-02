require 'rails_helper'

RSpec.describe Steps::Capital::PropertyAddressController, type: :controller do
  include_context 'current provider with active office'

  let(:form_class) { Steps::Capital::PropertyAddresForm }
  let(:decision_tree_class) { Decisions::CapitalDecisionTree }
  let(:crime_application) { CrimeApplication.create(office_code:) }
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
        Property.create!(property_type: PropertyType::RESIDENTIAL,
                         crime_application: CrimeApplication.create!(office_code:))
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
        steps_capital_property_address_form: address_attributes
      }
    end

    let(:address_attributes) do
      {
        address_line_one: 'address_line_one',
        address_line_two: 'address_line_two',
        city: 'city',
        country: 'country',
        postcode: 'postcode'
      }
    end

    context 'when valid address attributes' do
      it 'redirects to `properties_summary` page' do
        put :update, params: expected_params, session: { crime_application_id: crime_application.id }
        expect(response).to redirect_to edit_steps_capital_properties_summary_path
      end
    end

    context 'when invalid address attributes' do
      before { address_attributes.merge!(address_line_one: nil, city: nil) }

      it 'does not redirect to the `properties_summary` path' do
        put :update, params: expected_params, session: { crime_application_id: crime_application.id }
        expect(response).not_to redirect_to edit_steps_capital_properties_summary_path
      end
    end
  end
end
