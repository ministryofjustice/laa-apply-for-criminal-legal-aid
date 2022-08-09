require 'rails_helper'

RSpec.describe Steps::Address::ResultsForm do
  let(:arguments) { {
    crime_application: crime_application,
    record: address_record,
    lookup_id: lookup_id,
  } }

  let(:crime_application) { instance_double(CrimeApplication) }
  let(:address_record) { instance_double(Address, postcode: 'SW1H 0AX') }
  let(:lookup_id) { '23749191' }

  let(:lookup_service) { instance_double(OrdnanceSurvey::AddressLookup, call: lookup_results) }
  let(:lookup_results) { OrdnanceSurvey::AddressLookupResults.call(json_results) }

  let(:json_results) { JSON.parse(file_fixture('address_lookups/success.json').read)['results'] }

  subject { described_class.new(arguments) }

  before do
    allow(OrdnanceSurvey::AddressLookup).to receive(:new).and_return(lookup_service)
  end

  describe '.addresses' do
    context 'when 1 address is returned by the service' do
      it 'returns an array of Address struct' do
        expect(subject.addresses).to contain_exactly(Struct, Struct)
      end

      it 'contains an addresses count item' do
        expect(subject.addresses[0].lookup_id).to be_nil
        expect(subject.addresses[0].address_lines).to eq('1 address found')
      end

      it 'contains the addresses' do
        expect(subject.addresses[1].lookup_id).to eq('23749191')
        expect(subject.addresses[1].address_lines).to eq('1, POST OFFICE, BROADWAY')
      end
    end

    context 'when 2 or more addresses are returned by the service' do
      let(:json_results) { super() * 2 }

      it 'returns an array of Address struct' do
        expect(subject.addresses).to contain_exactly(Struct, Struct, Struct)
      end

      it 'contains an addresses count item' do
        expect(subject.addresses[0].lookup_id).to be_nil
        expect(subject.addresses[0].address_lines).to eq('2 addresses found')
      end

      # They are dupes but this is ok for this test scenario
      it 'contains the addresses' do
        expect(subject.addresses[1].lookup_id).to eq('23749191')
        expect(subject.addresses[1].address_lines).to eq('1, POST OFFICE, BROADWAY')

        expect(subject.addresses[2].lookup_id).to eq('23749191')
        expect(subject.addresses[2].address_lines).to eq('1, POST OFFICE, BROADWAY')
      end
    end

    context 'when no addresses are returned by the service' do
      let(:json_results) { [] }

      it 'returns an empty array' do
        expect(subject.addresses).to eq([])
      end
    end
  end

  describe 'lookup_id validation' do
    context 'when the ID is found in the results' do
      it 'does not have an error on the attribute' do
        expect(subject).to be_valid
      end
    end

    context 'when the ID is not found in the results' do
      let(:lookup_id) { '12345' }

      it 'adds an `inclusion` error on the attribute' do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:lookup_id, :inclusion)).to eq(true)
      end
    end

    context 'when the ID is blank' do
      let(:lookup_id) { '' }

      it 'adds an `inclusion` error on the attribute' do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:lookup_id, :inclusion)).to eq(true)
      end
    end
  end

  describe '#save' do
    context 'for valid details' do
      it 'updates the record' do
        expect(address_record).to receive(:update).with(
          address_line_one: '1, POST OFFICE',
          address_line_two: 'BROADWAY',
          city: 'LONDON',
          country: 'UNITED KINGDOM',
          postcode: 'SW1H 0AX',
          lookup_id: '23749191',
        ).and_return(true)

        expect(subject.save).to be(true)
      end
    end
  end
end
