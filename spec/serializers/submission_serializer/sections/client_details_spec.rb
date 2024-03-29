require 'rails_helper'

RSpec.describe SubmissionSerializer::Sections::ClientDetails do
  subject { described_class.new(crime_application) }

  let(:crime_application) { instance_double(CrimeApplication, applicant:) }

  let(:applicant) do
    instance_double(
      Applicant,
      first_name: 'Max',
      last_name: 'Mustermann',
      other_names: '',
      date_of_birth: date_of_birth,
      nino: 'AB123456A',
      benefit_type: 'universal_credit',
      home_address: home_address,
      correspondence_address: correspondence_address,
      telephone_number: '123456789',
      correspondence_address_type: 'home_address',
    )
  end

  let(:date_of_birth) { DateTime.new(1950, 1, 1) }

  let(:home_address) do
    instance_double(
      HomeAddress,
      address_line_one: 'Test',
      address_line_two: 'Home',
      postcode: 'A11 1XX',
      city: 'City',
      country: 'Country',
      lookup_id: 1,
    )
  end

  let(:correspondence_address) do
    # Incomplete address, on purpose
    CorrespondenceAddress.new(postcode: 'A11 1XX')
  end

  let(:json_output) do
    {
      client_details: {
        applicant: {
          first_name: 'Max',
          last_name: 'Mustermann',
          other_names: '',
          date_of_birth: date_of_birth,
          nino: 'AB123456A',
          benefit_type: 'universal_credit',
          home_address: {
            address_line_one: 'Test',
            address_line_two: 'Home',
            city: 'City',
            country: 'Country',
            postcode: 'A11 1XX',
            lookup_id: 1,
          },
          correspondence_address: nil,
          telephone_number: '123456789',
          correspondence_address_type: 'home_address',
        }
      }
    }.as_json
  end

  describe '#generate' do
    it { expect(subject.generate).to eq(json_output) }
  end
end
