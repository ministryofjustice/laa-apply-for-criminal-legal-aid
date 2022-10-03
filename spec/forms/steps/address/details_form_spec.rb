require 'rails_helper'

RSpec.describe Steps::Address::DetailsForm do
  subject { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application: crime_application,
      record: address_record,
    }.merge(address_attrs)
  end

  let(:crime_application) { instance_double(CrimeApplication) }
  let(:address_record) { Address.new }

  let(:address_attrs) do
    {
      address_line_one: 'Address line 1',
    address_line_two: 'Address line 2',
    city: 'City',
    country: 'Country',
    postcode: 'Postcode',
    }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:address_line_one) }
    it { is_expected.to validate_presence_of(:city) }
    it { is_expected.to validate_presence_of(:country) }
    it { is_expected.to validate_presence_of(:postcode) }

    it { is_expected.not_to validate_presence_of(:address_line_two) }
  end

  describe '#save' do
    context 'for valid details' do
      context 'when the address has changed' do
        it 'updates the record' do
          expect(address_record).to receive(:update).with(
            address_attrs.stringify_keys.merge(
              lookup_id: nil
            )
          ).and_return(true)

          expect(subject.save).to be(true)
        end
      end

      context 'when the address is the same as in the persisted record' do
        let(:address_record) do
          Address.new(address_attrs)
        end

        it 'does not save the record but returns true' do
          expect(address_record).not_to receive(:update)
          expect(subject.save).to be(true)
        end
      end
    end
  end
end
