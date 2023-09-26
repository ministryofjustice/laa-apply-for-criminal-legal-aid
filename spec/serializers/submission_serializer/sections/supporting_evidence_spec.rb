require 'rails_helper'

RSpec.describe SubmissionSerializer::Sections::SupportingEvidence do
  subject { described_class.new(crime_application) }

  let(:crime_application) do
    document = instance_double(
      Document,
      filename: 'test.pdf',
      s3_object_key: '123/abcdef1234',
      content_type: 'application/pdf',
      file_size: 12,
    )

    bundle = instance_double(
      DocumentBundle,
      documents: double(uploaded_to_s3: [document])
    )

    instance_double(
      CrimeApplication, document_bundles: [bundle]
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
