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
      property_type: PropertyType.values.sample,
      house_type: HouseType.values.sample,
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
    subject(:complete) { instance.complete? }

    context 'when initialized' do
      it { is_expected.to be false }
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
    let(:attributes) { required_attributes }

    context 'when client has partner' do
      let(:client_has_partner) { 'yes' }

      it { expect(instance.include_partner?).to be true }
    end

    context 'when client has no partner' do
      let(:client_has_partner) { 'no' }

      it { expect(instance.include_partner?).to be false }
    end
  end
end
