require 'rails_helper'

RSpec.describe Steps::Capital::OtherPropertyTypeForm do
  subject(:form) { described_class.new(crime_application:) }

  let(:crime_application) { instance_double(CrimeApplication, properties:) }
  let(:properties) { class_double(Property, where: existing_properties) }
  let(:existing_properties) { [instance_double(Property, complete?: false)] }
  let(:property_type) { PropertyType::RESIDENTIAL.to_s }
  let(:new_property) { instance_double(Property) }

  describe '#save' do
    before do
      allow(properties).to receive(:create).with(property_type:).and_return new_property

      form.property_type = property_type
      form.save
    end

    context 'when a property of the type exists' do
      it 'a new property of the property type is created' do
        expect(form.property).to be new_property
        expect(properties).to have_received(:create).with(property_type:)
      end
    end
  end
end
