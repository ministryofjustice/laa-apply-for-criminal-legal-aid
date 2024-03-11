require 'rails_helper'

RSpec.describe Steps::Capital::PropertyTypeForm do
  subject(:form) { described_class.new(crime_application:) }

  let(:crime_application) { instance_double(CrimeApplication, properties:) }
  let(:properties) { class_double(Property, where: existing_properties) }
  let(:existing_properties) { [] }

  describe '#choices' do
    it 'returns the possible choices' do
      expect(
        form.choices
      ).to eq([PropertyType::RESIDENTIAL, PropertyType::COMMERCIAL, PropertyType::LAND])
    end
  end

  describe '#save' do
    let(:property_type) { PropertyType::RESIDENTIAL.to_s }
    let(:new_property) { instance_double(Property, property_type:) }
    let(:existing_property) { instance_double(Property, property_type: property_type, complete?: complete?) }
    let(:complete?) { false }

    before do
      allow(properties).to receive(:create).with(property_type:).and_return new_property

      form.property_type = property_type
      form.save
    end

    context 'when client has no properties' do
      let(:property_type) { 'none' }

      it 'returns true but does not set or create a property' do
        expect(form.property).to be_nil
        expect(properties).not_to have_received(:create)
      end
    end

    context 'when there are no properties of the property type' do
      it 'a new property of the property type is created' do
        expect(form.property).to be new_property
        expect(properties).to have_received(:create).with(property_type:)
      end
    end

    context 'when a property of the type exists' do
      let(:existing_properties) { [existing_property] }

      it 'is set as the property' do
        expect(form.property).to be existing_property
        expect(properties).not_to have_received(:create)
      end

      context 'when the existing property is complete' do
        let(:complete?) { true }

        it 'a new property of the property type is created' do
          expect(form.property).to be new_property
          expect(properties).to have_received(:create).with(property_type:)
        end
      end
    end
  end
end
