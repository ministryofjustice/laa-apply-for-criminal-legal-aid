require 'rails_helper'

RSpec.describe Steps::Address::LookupForm do
  let(:arguments) { {
    crime_application: crime_application,
    record: address_record,
    postcode: 'SW1H 9AJ',
  } }

  let(:crime_application) { instance_double(CrimeApplication) }
  let(:address_record) { Address.new }

  subject { described_class.new(arguments) }

  describe 'validations' do
    it { should validate_presence_of(:postcode) }
  end

  describe '#save' do
    context 'when the attribute is given but is not a valid postcode' do
      let(:postcode) { 'SE1' }

      xit 'adds an `invalid` error on the attribute' do
        expect(subject).not_to be_valid
        expect(subject.errors.added?(:postcode, :invalid)).to eq(true)
      end
    end

    context 'for valid details' do
      before do
        allow(address_record).to receive(:postcode).and_return(previous_postcode)
      end

      context 'when the postcode has changed' do
        let(:previous_postcode) { 'SW1A 1AA' }

        it 'updates the record' do
          expect(address_record).to receive(:update).with(
            'postcode' => 'SW1H 9AJ',
            address_line_one: nil,
            address_line_two: nil,
            city: nil,
            country: nil,
            lookup_id: nil
          ).and_return(true)

          expect(subject.save).to be(true)
        end
      end

      context 'when the postcode is the same as in the persisted record' do
        let(:previous_postcode) { 'SW1H 9AJ' }

        it 'does not save the record but returns true' do
          expect(address_record).not_to receive(:update)
          expect(subject.save).to be(true)
        end
      end
    end
  end
end
