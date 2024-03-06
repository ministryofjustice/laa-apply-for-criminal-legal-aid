require 'rails_helper'

RSpec.describe Steps::Capital::PropertyOwnerForm do
  # rubocop:disable Layout/LineLength
  subject { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application: crime_application,
      record: property_record,
      property_owners_attributes: property_owners_attributes
    }
  end

  let(:crime_application) { instance_double(CrimeApplication) }
  let(:property_record) { Property.new(property_type: PropertyType::RESIDENTIAL.to_s) }

  let(:property_owners_attributes1) {
    { 'name' => 'a', 'relationship' => RelationshipType::FRIENDS.to_s, 'custom_relationship' => '', 'percentage_owned' => '50' }
  }
  let(:property_owners_attributes2) {
    { 'name' => 'b', 'relationship' => RelationshipType::EX_PARTNER.to_s, 'custom_relationship' => '', 'percentage_owned' => '20' }
  }
  let(:property_owners_attributes3) {
    { 'name' => 'c', 'relationship' => Steps::Capital::PropertyOwnerFieldsetForm::CUSTOM_RELATIONSHIP, 'custom_relationship' => 'custom relationship name', 'percentage_owned' => '10' }
  }

  let(:property_owners_attributes) do
    {
      '0' => property_owners_attributes1,
      '1' => property_owners_attributes2,
      '2' => property_owners_attributes3
    }
  end

  describe 'validations' do
    context 'property owners' do
      let(:property_owners_attributes) do
        {
          '0' => property_owners_attributes1.merge('name' => '', 'percentage_owned' => ''),
          '1' => property_owners_attributes2.merge('relationship' => ''),
          '2' => property_owners_attributes3.merge('custom_relationship' => '')
        }
      end

      before do
        expect(subject).not_to be_valid
        expect(subject.save).to be(false)
      end

      it 'has errors when name is blank' do
        expect(subject.errors.of_kind?('property_owner-attributes[0].name', :blank)).to be(true)
        expect(subject.errors.messages_for('property_owner-attributes[0].name').first).to eq(
          'Enter the name of the [first] other owner'
        )
      end

      it 'has errors when the relationship is blank' do
        expect(subject.errors.of_kind?('property_owner-attributes[1].relationship', :blank)).to be(true)
        expect(subject.errors.messages_for('property_owner-attributes[1].relationship').first).to eq(
          'Enter their relationship to your client'
        )
      end

      it 'has errors when the relationship is custom and custom_relationship is blank' do
        expect(subject.errors.of_kind?('property_owner-attributes[2].custom_relationship', :blank)).to be(true)
        expect(subject.errors.messages_for('property_owner-attributes[2].custom_relationship').first).to eq(
          'Enter their relationship'
        )
      end

      it 'has errors when percentage_owned is blank' do
        expect(subject.errors.of_kind?('property_owner-attributes[0].percentage_owned', :blank)).to be(true)
        expect(subject.errors.messages_for('property_owner-attributes[0].percentage_owned').first).to eq(
          'Enter the percentage of the land they own'
        )
      end
    end

    describe '#any_marked_for_destruction?' do
      # NOTE: this scenario requires real DB records to exercise nested attributes
      context 'there are property owners marked for destruction' do
        let(:application) { CrimeApplication.create }

        let(:property_owners) do
          [
            PropertyOwner.new(**property_owners_attributes1),
            PropertyOwner.new(**property_owners_attributes2)
          ]
        end

        let(:property_record) {
          Property.create(crime_application: application, property_owners: property_owners,
                          property_type: PropertyType::RESIDENTIAL.to_s)
        }

        let(:property_owners_attributes) do
          {
            '0' => property_owners_attributes1.merge('id' => property_owners[0].id.to_s, '_destroy' => '1'),
            '1' => property_owners_attributes2.merge('id' => property_owners[1].id.to_s)
          }
        end

        it 'returns true' do
          expect(subject.any_marked_for_destruction?).to be(true)
          expect(subject.property_owners[0]._destroy).to be(true)
          expect(subject.property_owners[1]._destroy).to be(false)
        end
      end

      context 'there are no property_owners to be destroyed' do
        it { expect(subject.any_marked_for_destruction?).to be(false) }
      end
    end
  end

  describe '#save' do
    context 'for valid details' do
      it 'updates the record' do
        expect(property_record).to receive(:update).with(
          {
            property_owners_attributes:,
          }
        ).and_return(true)

        expect(subject.save).to be(true)
      end
    end
  end

  describe '#property_owners' do
    it 'returns a list of property owner fieldset forms' do
      expect(subject.property_owners).to all(be_a(Steps::Capital::PropertyOwnerFieldsetForm))
      expect(subject.property_owners.size).to be(3)
    end
  end

  describe '#show_destroy?' do
    context 'if there are fewer than two property owners' do
      let(:property_owners_attributes) do
        {
          '0' => property_owners_attributes1
        }
      end

      it 'returns false' do
        expect(subject.show_destroy?).to be(false)
      end
    end

    context 'if there two or more property owners' do
      let(:property_owners_attributes) do
        {
          '0' => property_owners_attributes1,
          '1' => property_owners_attributes2
        }
      end

      it 'returns true' do
        expect(subject.show_destroy?).to be(true)
      end
    end
  end
  # rubocop:enable Layout/LineLength
end
