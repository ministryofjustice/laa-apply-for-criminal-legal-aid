require 'rails_helper'

RSpec.describe Property, type: :model do
  subject(:instance) { described_class.new(attributes) }

  let(:attributes) { { id: nil } }
  let(:crime_application) { CrimeApplication.create(client_has_partner:) }
  let(:client_has_partner) { 'no' }
  let(:property_type) { PropertyType::RESIDENTIAL.to_s }
  let(:is_home_address) { 'yes' }
  let(:has_other_owners) { 'no' }

  let(:required_attributes) do
    {
      id: SecureRandom.uuid,
      crime_application: crime_application,
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
      address: nil,
    }
  end

  describe '#complete?' do
    subject { instance.complete? }

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

  describe '#include_partner?' do
    subject { instance.include_partner? }

    let(:attributes) { required_attributes }

    context 'when client has partner' do
      let(:client_has_partner) { 'yes' }

      it { is_expected.to be true }
    end

    context 'when client has no partner' do
      let(:client_has_partner) { 'no' }

      it { is_expected.to be false }
    end
  end

  describe '#address_complete?' do
    subject { instance.address_complete? }

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
    end

    context 'when property has no other owners' do
      let(:has_other_owners) { 'no' }
      let(:attributes) { required_attributes.merge(property_owners: []) }

      it { is_expected.to be true }
    end
  end
end
