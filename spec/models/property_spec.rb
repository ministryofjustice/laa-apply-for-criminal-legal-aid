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
      property_type: PropertyType::RESIDENTIAL.to_s,
      house_type: HouseType.values.sample.to_s,
      bedrooms: 2,
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

    context 'when initialized' do
      it { expect { subject }.to raise_error(RuntimeError, /Unsupported Asset/) }
    end

    context 'when property_type is residential' do
      context 'when all provided attributes are present' do
        let(:attributes) { required_attributes }

        it { is_expected.to be true }
      end

      context 'when any required attributes are missing' do
        let(:attributes) { required_attributes.merge(outstanding_mortgage: nil) }

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
end
