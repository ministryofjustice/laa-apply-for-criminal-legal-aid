require 'rails_helper'

RSpec.describe Steps::Address::ResultsForm do
  subject { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application: crime_application,
      record: address_record,
      lookup_id: lookup_id,
    }
  end

  let(:crime_application) { instance_double(CrimeApplication) }
  let(:address_record) { Address.new(postcode: 'SW1H 0AX') }
  let(:lookup_id) { '23749191' }

  let(:lookup_service) { instance_double(OrdnanceSurvey::AddressLookup, call: lookup_results) }
  let(:lookup_results) { OrdnanceSurvey::AddressLookupResults.call(json_results) }

  let(:json_results) { JSON.parse(file_fixture('address_lookups/success.json').read)['results'] }

  before do
    allow(OrdnanceSurvey::AddressLookup).to receive(:new).and_return(lookup_service)
  end

  describe '.addresses' do
    context 'when results are returned by the service' do
      let(:json_results) { super() * 2 }

      it 'returns an array of Address struct' do
        expect(subject.addresses).to contain_exactly(Struct, Struct)
      end

      # They are dupes but this is ok for this test scenario
      it 'contains the addresses' do
        expect(subject.addresses[0].lookup_id).to eq('23749191')
        expect(subject.addresses[0].compact_address).to eq('1, POST OFFICE, BROADWAY, LONDON')

        expect(subject.addresses[1].lookup_id).to eq('23749191')
        expect(subject.addresses[1].compact_address).to eq('1, POST OFFICE, BROADWAY, LONDON')
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
        expect(subject.errors.of_kind?(:lookup_id, :inclusion)).to be(true)
      end
    end

    context 'when the ID is blank' do
      let(:lookup_id) { '' }

      it 'adds an `inclusion` error on the attribute' do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:lookup_id, :inclusion)).to be(true)
      end
    end
  end

  describe '#save' do
    before do
      allow(address_record).to receive(:lookup_id).and_return(previous_lookup_id)
    end

    context 'when the `lookup_id` has changed' do
      let(:previous_lookup_id) { '99999' }

      it 'updates the record' do
        expect(address_record).to receive(:update).with(
          {
            address_line_one: '1, POST OFFICE',
            address_line_two: 'BROADWAY',
            city: 'LONDON',
            country: 'UNITED KINGDOM',
            postcode: 'SW1H 0AX',
            lookup_id: '23749191',
          }
        ).and_return(true)

        expect(subject.save).to be(true)
      end
    end

    context 'when the `lookup_id` is the same as in the persisted record' do
      let(:previous_lookup_id) { '23749191' }

      it 'does not save the record but returns true' do
        expect(address_record).not_to receive(:update)
        expect(subject).not_to receive(:address_ids)
        expect(subject.save).to be(true)
      end
    end
  end
end
