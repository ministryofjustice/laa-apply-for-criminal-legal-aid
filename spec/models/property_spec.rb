require 'rails_helper'

RSpec.describe Property, type: :model do
  subject(:instance) { described_class.new(attributes) }

  let(:attributes) { { id: nil } }
  let(:crime_application) { CrimeApplication.create(client_has_partner:) }
  let(:client_has_partner) { 'no' }

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
      is_home_address: 'yes',
      has_other_owners: 'no',
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

    let(:property_type) { PropertyType::RESIDENTIAL.to_s }
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
end
