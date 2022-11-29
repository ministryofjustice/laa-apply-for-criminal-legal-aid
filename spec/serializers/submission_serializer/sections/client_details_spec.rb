require 'rails_helper'

RSpec.describe SubmissionSerializer::Sections::ClientDetails do
  subject { described_class.new(crime_application) }

  let(:crime_application) { instance_double(CrimeApplication) }
  let(:applicant) do
    instance_double(
      Applicant,
      first_name: 'Max',
      last_name: 'Mustermann',
      date_of_birth: date_of_birth,
      home_address: home_address,
    )
  end

  let(:date_of_birth) { DateTime.new(1950, 1, 1) }

  let(:home_address) do
    HomeAddress.new(
      address_line_one: 'Test',
      address_line_two: 'Home',
      postcode: 'A11 1XX',
      city: 'City',
      country: 'Country',
    )
  end

  let(:json_output) do
    {
      client_details: {
        applicant: {
          address: {
            address_line_one: 'Test',
            address_line_two: 'Home',
            city: 'City',
            country: 'Country',
            postcode: 'A11 1XX',
          },
          date_of_birth: date_of_birth,
          first_name: 'Max',
          last_name: 'Mustermann'
        }
      }
    }.as_json
  end

  before do
    allow(crime_application).to receive(:applicant).and_return(applicant)
  end

  describe '#generate' do
    it { expect(subject.generate).to eq(json_output) }
  end
end
