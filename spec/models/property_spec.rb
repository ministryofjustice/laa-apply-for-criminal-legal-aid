require 'rails_helper'

RSpec.describe Property, type: :model do
  subject(:instance) { described_class.new(attributes) }

  let(:attributes) { { id: nil } }

  describe '#complete?' do
    subject(:complete) { instance.complete? }

    context 'when initialized' do
      it { is_expected.to be false }
    end

    context 'when property_type is residential' do
      let(:required_attributes) do
        {
          id: SecureRandom.uuid,
          person_id: SecureRandom.uuid,
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
end
