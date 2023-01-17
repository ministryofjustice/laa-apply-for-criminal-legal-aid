require 'rails_helper'

RSpec.describe Adapters::Structs::Applicant do
  subject { described_class.new(applicant) }

  let(:application_struct) do
    Adapters::Structs::CrimeApplication.new(
      JSON.parse(LaaCrimeSchemas.fixture(1.0).read)
    )
  end

  let(:applicant) { application_struct.applicant }

  describe '#first_name' do
    it 'returns the applicant first name' do
      expect(subject.first_name).to eq('Kit')
    end
  end

  describe '#last_name' do
    it 'returns the applicant first name' do
      expect(subject.last_name).to eq('Pound')
    end
  end

  describe '#full_name' do
    it 'returns the applicant full name' do
      expect(subject.full_name).to eq('Kit Pound')
    end
  end

  describe '#passporting_benefit' do
    it 'returns always true for MVP' do
      expect(subject.passporting_benefit).to be(true)
    end
  end

  describe '#has_nino' do
    it 'returns always `yes` for MVP' do
      expect(subject.has_nino).to be(YesNoAnswer::YES)
    end
  end

  describe '#home_address' do
    it 'returns an `Address` instance if there is an address' do
      expect(subject.home_address).to be_an(Address)
    end
  end

  describe '#correspondence_address' do
    it 'returns nil if there is no address' do
      expect(subject.correspondence_address).to be_nil
    end
  end

  describe '#serializable_hash' do
    it 'returns a serializable hash, including relationships' do
      expect(
        subject.serializable_hash
      ).to match(
        a_hash_including(
          'has_nino' => YesNoAnswer::YES,
          'passporting_benefit' => true,
          'home_address' => an_instance_of(HomeAddress),
          'correspondence_address' => nil,
        )
      )
    end

    it 'contains all required attributes' do
      expect(
        subject.serializable_hash.keys
      ).to match_array(
        %w[
          has_nino
          passporting_benefit
          first_name
          last_name
          date_of_birth
          nino
          correspondence_address_type
          telephone_number
          home_address
          correspondence_address
        ]
      )
    end

    context 'home_address relationship' do
      it 'has the expected address from the fixture' do
        address = subject.serializable_hash['home_address']

        expect(address.lookup_id).to be_nil
        expect(address.address_line_one).to eq('1 Road')
        expect(address.address_line_two).to eq('Village')
        expect(address.city).to eq('Some nice city')
        expect(address.country).to eq('United Kingdom')
        expect(address.postcode).to eq('SW1A 2AA')
      end
    end
  end
end
