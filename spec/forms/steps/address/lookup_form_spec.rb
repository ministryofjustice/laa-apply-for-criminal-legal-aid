require 'rails_helper'

RSpec.describe Steps::Address::LookupForm do
  let(:arguments) { {
    crime_application: crime_application,
    record: address_record,
    postcode: 'SW1H 9AJ',
  } }

  let(:crime_application) { instance_double(CrimeApplication) }
  let(:address_record) { instance_double(Address) }

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
      it 'updates the record' do
        expect(address_record).to receive(:update).with(
          'postcode' => 'SW1H 9AJ',
        ).and_return(true)

        expect(subject.save).to be(true)
      end
    end
  end
end
