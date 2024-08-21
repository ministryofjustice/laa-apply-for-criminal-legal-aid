require 'rails_helper'

RSpec.describe Steps::Capital::PropertyAddressForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application:,
      record:,
    }.merge(attributes)
  end

  let(:attributes) { valid_attributes }

  let(:crime_application) do
    instance_double(CrimeApplication)
  end
  let(:applicant) { instance_double(Applicant, home_address?: home_address?) }
  let(:record) { Property.new }

  describe '#save' do
    let(:valid_attributes) do
      {
        address_line_one: 'address_line_one',
        address_line_two: 'address_line_two',
        city: 'city',
        country: 'country',
        postcode: 'postcode'
      }
    end

    context 'with valid attributes' do
      it 'updates the record' do
        expect(record).to receive(:update).and_return(true)
        expect(subject.save).to be(true)
      end
    end

    context 'with invalid attributes' do
      context 'when address is not present' do
        let(:attributes) { {} }

        it 'does not updates the record' do
          expect(record).not_to receive(:update)
          expect(subject.save).to be(false)
        end
      end

      context 'when address is incomplete' do
        let(:attributes) { valid_attributes.merge(address_line_one: nil, city: nil) }

        it 'does not updates the record' do
          expect(record).not_to receive(:update)
          expect(subject.save).to be(false)
        end
      end
    end
  end
end
