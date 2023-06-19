require 'rails_helper'

RSpec.describe Steps::Address::LookupForm do
  subject { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application: crime_application,
      record: address_record,
      postcode: postcode,
      step_name: step_name,
    }
  end

  let(:crime_application) { instance_double(CrimeApplication) }
  let(:address_record) { Address.new }
  let(:postcode) { 'SW1H 9AJ' }
  let(:step_name) { :lookup }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:postcode) }

    context 'when clearing an address' do
      let(:step_name) { :clear_address }

      it { is_expected.not_to validate_presence_of(:postcode) }
    end
  end

  describe '#save' do
    context 'UK postcode validation' do
      context 'when postcode is incomplete' do
        let(:postcode) { 'SE1' }

        it 'adds an `invalid` error on the attribute' do
          expect(subject).not_to be_valid
          expect(subject.errors.added?(:postcode, :invalid)).to be(true)
        end
      end

      context 'when postcode is not valid' do
        let(:postcode) { 'SZ123A' }

        it 'adds an `invalid` error on the attribute' do
          expect(subject).not_to be_valid
          expect(subject.errors.added?(:postcode, :invalid)).to be(true)
        end
      end
    end

    context 'for valid details' do
      before do
        allow(address_record).to receive(:postcode).and_return(previous_postcode)
      end

      let(:previous_postcode) { 'SW1H 9AJ' }

      context 'when the postcode has changed' do
        let(:previous_postcode) { 'SW1A 1AA' }

        it 'updates the record' do
          expect(address_record).to receive(:update).with(
            {
              postcode: 'SW1H 9AJ',
              address_line_one: nil,
              address_line_two: nil,
              city: nil,
              country: nil,
              lookup_id: nil,
            }
          ).and_return(true)

          expect(subject.save).to be(true)
        end
      end

      context 'when the postcode is the same as in the persisted record' do
        it 'does not save the record but returns true' do
          expect(address_record).not_to receive(:update)
          expect(subject.save).to be(true)
        end
      end

      context 'when clearing an address' do
        let(:step_name) { :clear_address }

        it 'updates the record clearing all address attributes' do
          expect(address_record).to receive(:update).with(
            {
              postcode: nil,
              address_line_one: nil,
              address_line_two: nil,
              city: nil,
              country: nil,
              lookup_id: nil,
            }
          ).and_return(true)

          expect(subject.save).to be(true)
        end
      end
    end
  end
end
