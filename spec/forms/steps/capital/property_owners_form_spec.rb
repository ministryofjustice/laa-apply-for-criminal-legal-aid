require 'rails_helper'

RSpec.describe Steps::Capital::PropertyOwnersForm do
  # rubocop:disable Layout/LineLength
  subject { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application: crime_application,
      record: property_record,
      property_owners_attributes: property_owners_attributes,
      step_name: step_name,
    }
  end

  let(:crime_application) { CrimeApplication.new }
  let(:property_record) { Property.new(property_type: PropertyType::RESIDENTIAL.to_s, crime_application: crime_application, percentage_applicant_owned: percentage_applicant_owned) }

  let(:property_owners_attributes1) {
    { 'name' => 'a', 'relationship' => PropertyRelationshipType::FRIENDS.to_s, 'other_relationship' => nil, 'percentage_owned' => '40' }
  }
  let(:property_owners_attributes2) {
    { 'name' => 'b', 'relationship' => PropertyRelationshipType::EX_PARTNER.to_s, 'other_relationship' => nil, 'percentage_owned' => '40' }
  }
  let(:property_owners_attributes3) {
    { 'name' => 'c', 'relationship' => PropertyOwner::OTHER_RELATIONSHIP, 'other_relationship' => 'other relationship name', 'percentage_owned' => '10' }
  }

  let(:property_owners_attributes) do
    {
      '0' => property_owners_attributes1,
      '1' => property_owners_attributes2,
      '2' => property_owners_attributes3
    }
  end
  let(:percentage_applicant_owned) { 10 }
  let(:step_name) { :property_owners }

  describe 'validations' do
    context 'property owners' do
      let(:property_owners_attributes) do
        {
          '0' => property_owners_attributes1.merge('name' => nil, 'percentage_owned' => nil),
          '1' => property_owners_attributes2.merge('relationship' => nil),
          '2' => property_owners_attributes3.merge('other_relationship' => nil)
        }
      end

      before do
        expect(subject).not_to be_valid
        expect(subject.save).to be(false)
      end

      it 'has errors when name is blank' do
        expect(subject.errors.of_kind?('property_owners-attributes[0].name', :blank)).to be(true)
        expect(subject.errors.messages_for('property_owners-attributes[0].name').first).to eq(
          'Enter the name of the other owner'
        )
      end

      it 'has errors when the relationship is blank' do
        expect(subject.errors.of_kind?('property_owners-attributes[1].relationship', :blank)).to be(true)
        expect(subject.errors.messages_for('property_owners-attributes[1].relationship').first).to eq(
          'Enter their relationship to your client'
        )
      end

      it 'has errors when the relationship is other and other_relationship is blank' do
        expect(subject.errors.of_kind?('property_owners-attributes[2].other_relationship', :blank)).to be(true)
        expect(subject.errors.messages_for('property_owners-attributes[2].other_relationship').first).to eq(
          'Enter their relationship'
        )
      end

      it 'has errors when percentage_owned is blank' do
        expect(subject.errors.of_kind?('property_owners-attributes[0].percentage_owned', :blank)).to be(true)
        expect(subject.errors.messages_for('property_owners-attributes[0].percentage_owned').first).to eq(
          'Enter the percentage of the land they own'
        )
      end
    end

    context 'when total percentage ownership is not valid' do
      let(:property_owners_attributes3) {
        { 'name' => 'c', 'relationship' => PropertyOwner::OTHER_RELATIONSHIP, 'other_relationship' => 'other relationship name', 'percentage_owned' => '100' }
      }

      context 'when saving form' do
        before do
          expect(subject).not_to be_valid
          expect(subject.save).to be(false)
        end

        it 'has errors when when total percentage ownership is over 100' do
          attr = 'property_owners-attributes[2].percentage_owned'
          expect(subject.errors.of_kind?(attr, :invalid)).to be(true)
          expect(subject.errors.messages_for(attr).first).to eq(
            'The percentage of the property they own must be a number greater than 0 and less than 100'
          )
          expect(subject.errors.messages_for(attr).last).to eq(
            'Percentages entered need to total 100% - check percentage owned by other owner 3'
          )
        end

        context 'when percentage does not equal 100' do
          let(:property_owners_attributes3) {
            { 'name' => 'c', 'relationship' => PropertyOwner::OTHER_RELATIONSHIP, 'other_relationship' => 'other relationship name', 'percentage_owned' => '1' }
          }

          it 'errors on percentage ownership fields' do
            attr = 'property_owners-attributes[0].percentage_owned'
            attr2 = 'property_owners-attributes[1].percentage_owned'
            attr3 = 'property_owners-attributes[2].percentage_owned'

            expect(subject.errors.of_kind?(attr, :invalid)).to be(true)
            expect(subject.errors.messages_for(attr).first).to eq(
              'Percentages entered need to total 100% - check percentage owned by other owner 1'
            )
            expect(subject.errors.of_kind?(attr2, :invalid)).to be(true)
            expect(subject.errors.messages_for(attr2).first).to eq(
              'Percentages entered need to total 100% - check percentage owned by other owner 2'
            )
            expect(subject.errors.of_kind?(attr3, :invalid)).to be(true)
            expect(subject.errors.messages_for(attr3).first).to eq(
              'Percentages entered need to total 100% - check percentage owned by other owner 3'
            )
          end
        end
      end

      context 'when adding a property owner' do
        let(:step_name) { :add_property_owner }

        it 'does not perform the validation' do
          expect(subject).to be_valid
        end
      end
    end

    # rubocop:disable RSpec/MultipleMemoizedHelpers
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
  # rubocop:enable RSpec/MultipleMemoizedHelpers

  describe '#save' do
    context 'for valid details' do
      it 'updates the record' do
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

  describe '#relationships' do
    it 'returns the possible choices' do
      expect(subject.relationships.map(&:to_s)).to eq(
        %w[
          business_associates
          ex_partner
          family_members
          friends
          house_builder
          housing_association
          local_authority
          partner_with_a_contrary_interest
          property_company
        ]
      )
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
