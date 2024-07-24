require 'rails_helper'

RSpec.describe Property, type: :model do
  subject(:instance) { described_class.new(attributes) }

  let(:attributes) { { id: nil } }
  let(:property_type) { PropertyType::RESIDENTIAL.to_s }
  let(:is_home_address) { 'yes' }
  let(:has_other_owners) { 'no' }

  let(:required_attributes) do
    {
      id: SecureRandom.uuid,
      property_type: property_type,
      house_type: HouseType.values.sample.to_s,
      bedrooms: 2,
      usage: 'usage details',
      size_in_acres: 100,
      value: 300_000,
      outstanding_mortgage: 100_000,
      percentage_applicant_owned: 20,
      percentage_partner_owned: nil,
      is_home_address: is_home_address,
      has_other_owners: has_other_owners,
      address: nil
    }
  end

  describe '#complete?' do
    subject { instance.complete? }

    before do
      allow(instance).to receive(:property_ownership_valid?).and_return(true)
    end

    context 'when property_type is residential' do
      let(:property_type) { PropertyType::RESIDENTIAL.to_s }

      context 'when all provided attributes are present' do
        let(:attributes) { required_attributes.slice!(:usage, :size_in_acres) }

        it { is_expected.to be true }
      end

      context 'when any required attributes are missing' do
        let(:attributes) { required_attributes.merge(house_type: nil) }

        it { is_expected.to be false }
      end
    end

    context 'when property_type is commercial' do
      let(:property_type) { PropertyType::COMMERCIAL.to_s }

      context 'when all provided attributes are present' do
        let(:attributes) { required_attributes.slice!(:house_type, :bedrooms) }

        it { is_expected.to be true }
      end

      context 'when any required attributes are missing' do
        let(:attributes) { required_attributes.merge(usage: nil) }

        it { is_expected.to be false }
      end
    end

    context 'when property_type is land' do
      let(:property_type) { PropertyType::LAND.to_s }

      context 'when all provided attributes are present' do
        let(:attributes) { required_attributes.slice!(:house_type, :bedrooms) }

        it { is_expected.to be true }
      end

      context 'when any required attributes are missing' do
        let(:attributes) { required_attributes.merge(size_in_acres: nil) }

        it { is_expected.to be false }
      end
    end
  end

  describe '#address_complete?' do
    subject { instance.address_complete? }

    context 'when property address question is not asked' do
      let(:is_home_address) { nil }
      let(:attributes) { required_attributes }

      it { is_expected.to be true }
    end

    context 'when property address question is asked' do
      context 'when property address is same as home address' do
        let(:is_home_address) { 'yes' }
        let(:attributes) { required_attributes }

        it { is_expected.to be true }
      end

      context 'when property address is different than home address' do
        let(:is_home_address) { 'no' }
        let(:address_attributes) do
          {
            'address_line_one' => 'address_line_one',
            'address_line_two' => 'address_line_two',
            'city' => 'city',
            'country' => 'country',
            'postcode' => 'postcode'
          }
        end

        context 'with valid address attributes' do
          let(:attributes) do
            required_attributes.merge(address: address_attributes)
          end

          it { is_expected.to be true }
        end

        context 'with invalid address attributes' do
          let(:attributes) do
            required_attributes.merge(address: address_attributes.merge('address_line_one' => ''))
          end

          it { expect(subject).to be false }
        end
      end
    end
  end

  describe '#property_owners_complete?' do
    subject { instance.property_owners_complete? }

    let(:property_owner1) {
      PropertyOwner.new(
        name: 'Chester Ratliff',
        relationship: 'housing_association',
        other_relationship: '',
        percentage_owned: 87.35
      )
    }

    let(:property_owner2) {
      PropertyOwner.new(
        name: 'Jow',
        relationship: 'other',
        other_relationship: 'other relationship',
        percentage_owned: 10
      )
    }

    context 'when property has other owners' do
      let(:has_other_owners) { 'yes' }

      context 'with complete property owner attributes' do
        let(:attributes) do
          required_attributes.merge(property_owners: [property_owner1, property_owner2])
        end

        it { is_expected.to be true }
      end

      context 'with incomplete property owner attributes' do
        before do
          property_owner2.relationship = ''
        end

        let(:attributes) do
          required_attributes.merge(property_owners: [property_owner1, property_owner2])
        end

        it { is_expected.to be false }
      end

      context 'with property owners missing' do
        let(:attributes) do
          required_attributes.merge(property_owners: [])
        end

        it { is_expected.to be false }
      end
    end

    context 'when property has no other owners' do
      let(:has_other_owners) { 'no' }
      let(:attributes) { required_attributes.merge(property_owners: []) }

      it { is_expected.to be true }
    end
  end

  describe '#has_percentage_complete?' do
    subject { instance.property_ownership_valid? }

    context 'when partner is not present' do
      context 'when valid' do
        let(:attributes) { required_attributes.merge(percentage_applicant_owned: 100) }

        it { is_expected.to be true }
      end

      context 'when invalid' do
        let(:attributes) { required_attributes.merge(percentage_applicant_owned: 60) }

        it { is_expected.to be false }
      end

      context 'when other owners are present' do
        let(:has_other_owners) { 'yes' }

        context 'when valid' do
          let(:attributes) {
            required_attributes.merge(
              percentage_applicant_owned: 60,
              property_owners: [PropertyOwner.new(percentage_owned: 40, name: 'name', relationship: 'relationship')]
            )
          }

          it { is_expected.to be true }
        end

        context 'when invalid' do
          let(:attributes) {
            required_attributes.merge(
              percentage_applicant_owned: 50,
              property_owners: [PropertyOwner.new(percentage_owned: 40, name: 'name', relationship: 'relationship')]
            )
          }

          it { is_expected.to be false }
        end
      end
    end

    context 'when partner is present' do
      context 'when valid' do
        let(:attributes) { required_attributes.merge(percentage_applicant_owned: 60, percentage_partner_owned: 40) }

        it { is_expected.to be true }
      end

      context 'when invalid' do
        let(:attributes) { required_attributes.merge(percentage_applicant_owned: 60, percentage_partner_owned: 30) }

        it { is_expected.to be false }
      end

      context 'when other owners are present' do
        let(:has_other_owners) { 'yes' }

        context 'when valid' do
          let(:attributes) {
            required_attributes.merge(
              percentage_applicant_owned: 60,
              percentage_partner_owned: 30,
              property_owners: [PropertyOwner.new(percentage_owned: 10, name: 'name', relationship: 'relationship')]
            )
          }

          it { is_expected.to be true }
        end

        context 'when invalid' do
          let(:attributes) {
            required_attributes.merge(
              percentage_applicant_owned: 50,
              percentage_partner_owned: 30,
              property_owners: [PropertyOwner.new(percentage_owned: 10, name: 'name', relationship: 'relationship')]
            )
          }

          it { is_expected.to be false }
        end
      end
    end
  end
end
