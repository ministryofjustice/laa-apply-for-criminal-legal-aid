require 'rails_helper'

RSpec.describe Steps::Capital::PropertyTypeForm do
  subject(:form) { described_class.new(crime_application:) }

  let(:crime_application) { instance_double(CrimeApplication, properties:, capital:) }
  let(:capital) { instance_double(Capital) }
  let(:properties) { class_double(Property, where: existing_properties) }
  let(:existing_properties) { [] }

  describe '#choices' do
    it 'returns the possible choices' do
      expect(
        form.choices
      ).to eq([PropertyType::RESIDENTIAL, PropertyType::COMMERCIAL, PropertyType::LAND])
    end
  end

  describe '#property_type' do
    subject(:property_type) { form.property_type }

    context 'when the question has not been answered' do
      before { allow(capital).to receive(:has_no_properties).and_return(nil) }

      it { is_expected.to be_nil }
    end

    context 'when capital#has_no_properties "yes"' do
      before { allow(capital).to receive(:has_no_properties).and_return('yes') }

      it { is_expected.to eq 'none' }
    end
  end

  describe '#validations' do
    before do
      allow(form).to receive(:include_partner_in_means_assessment?) { include_partner? }
      form.property_type = nil
    end

    let(:include_partner?) { false }

    let(:error_message) do
      'Select which assets your client owns or part-owns inside or outside the UK, ' \
        "or select 'They do not own any of these assets'"
    end

    it { is_expected.to validate_presence_of(:property_type, :blank, error_message) }

    context 'when partner is included in means assessment' do
      let(:include_partner?) { true }

      let(:error_message) do
        'Select which assets your client or their partner owns or part-owns inside ' \
          "or outside the UK, or select 'They do not own any of these assets'"
      end

      it { is_expected.to validate_presence_of(:property_type, :blank, error_message) }
    end
  end

  describe '#save' do
    let(:property_type) { PropertyType::RESIDENTIAL.to_s }
    let(:new_property) { instance_double(Property, property_type:) }
    let(:existing_property) { instance_double(Property, property_type: property_type, complete?: complete?) }
    let(:complete?) { false }

    before do
      allow(properties).to receive(:create!).with(property_type:).and_return new_property
      allow(capital).to receive(:update).and_return true
      allow(properties).to receive(:destroy_all)

      form.property_type = property_type
      form.save
    end

    context 'when client has no properties' do
      let(:property_type) { 'none' }

      it 'returns true but does not set or create a property' do
        expect(form.property).to be_nil
        expect(properties).not_to have_received(:create!)
      end

      it 'updates the capital#has_no_properties to "yes"' do
        expect(capital).to have_received(:update).with(has_no_properties: 'yes')
      end
    end

    context 'when there are no properties of the property type' do
      it 'a new property of the property type is created' do
        expect(form.property).to be new_property
        expect(properties).to have_received(:create!).with(property_type:)
      end

      it 'sets capital#has_no_properties to nil' do
        expect(capital).to have_received(:update).with(has_no_properties: nil)
      end
    end

    context 'when a property of the type exists' do
      let(:existing_properties) { [existing_property] }

      it 'is set as the property' do
        expect(form.property).to be existing_property
        expect(properties).not_to have_received(:create!)
      end

      context 'when the existing property is complete' do
        let(:complete?) { true }

        it 'a new property of the property type is created' do
          expect(form.property).to be new_property
          expect(properties).to have_received(:create!).with(property_type:)
        end
      end

      context 'when client selects `no assets` option after adding assets' do
        let(:property_type) { 'none' }

        it 'deletes existing properties' do
          expect(properties).to have_received(:destroy_all)
          expect(properties).not_to have_received(:create!)
        end
      end
    end
  end
end
