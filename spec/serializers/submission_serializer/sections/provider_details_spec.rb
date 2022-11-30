require 'rails_helper'

RSpec.describe SubmissionSerializer::Sections::ProviderDetails do
  subject { described_class.new(crime_application) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
    )
  end

  let(:json_output) do
    {
      provider_details: {}
    }.as_json
  end

  describe '#generate' do
    it { expect(subject.generate).to eq(json_output) }
  end
end
