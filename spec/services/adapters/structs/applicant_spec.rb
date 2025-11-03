require 'rails_helper'

RSpec.describe Adapters::Structs::Applicant do
  subject { application_struct.applicant }

  let(:application_struct) { build_struct_application }

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
          'home_address' => an_instance_of(HomeAddress),
          'correspondence_address' => nil,
        )
      )
    end

    # rubocop:disable RSpec/ExampleLength
    it 'contains all required attributes' do
      expect(
        subject.serializable_hash.keys
      ).to match_array(
        %w[
          first_name
          last_name
          other_names
          date_of_birth
          nino
          arc
          benefit_type
          last_jsa_appointment_date
          correspondence_address_type
          telephone_number
          home_address
          correspondence_address
          preferred_correspondence_language
          has_nino
          has_arc
          residence_type
          relationship_to_owner_of_usual_home_address
          has_partner
          benefit_check_result
          benefit_check_status
          relationship_status
          relationship_to_partner
          separation_date
          will_enter_nino
          has_benefit_evidence
          confirm_details
          confirm_dwp_result
          dwp_response
        ]
      )
    end
    # rubocop:enable RSpec/ExampleLength

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
