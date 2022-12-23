require 'rails_helper'

RSpec.describe SubmissionSerializer::Sections::ProviderDetails do
  subject { described_class.new(crime_application) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      office_code: 'XYZ',
      legal_rep_first_name: 'John',
      legal_rep_last_name: 'Doe',
      legal_rep_telephone: '123456789',
    )
  end

  let(:json_output) do
    {
      provider_details: {
        office_code: 'XYZ',
        legal_rep_first_name: 'John',
        legal_rep_last_name: 'Doe',
        legal_rep_telephone: '123456789',
      }
    }.as_json
  end

  describe '#generate' do
    it { expect(subject.generate).to eq(json_output) }
  end
end
