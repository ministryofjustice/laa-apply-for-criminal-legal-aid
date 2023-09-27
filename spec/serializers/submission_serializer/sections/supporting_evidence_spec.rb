require 'rails_helper'

RSpec.describe SubmissionSerializer::Sections::SupportingEvidence do
  subject { described_class.new(crime_application) }

  let(:document) do
    instance_double(
      Document,
      filename: 'test.pdf',
      s3_object_key: '123/abcdef1234',
      content_type: 'application/pdf',
      file_size: 12,
    )
  end

  let(:crime_application) do
    instance_double(
      CrimeApplication, documents: double(stored: [document])
    )
  end

  let(:json_output) do
    {
      supporting_evidence: [{
        filename: 'test.pdf',
        s3_object_key: '123/abcdef1234',
        content_type: 'application/pdf',
        file_size: 12,
      }]
    }.as_json
  end

  describe '#generate' do
    it { expect(subject.generate).to eq(json_output) }
  end
end
