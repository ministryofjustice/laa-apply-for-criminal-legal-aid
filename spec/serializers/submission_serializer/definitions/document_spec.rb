require 'rails_helper'

RSpec.describe SubmissionSerializer::Definitions::Document do
  subject { described_class.generate(documents) }

  let(:documents) { [document1, document2] }

  let(:document1) do
    instance_double(
      Document,
      s3_object_key: '123/abcdef1234',
      filename: 'test.pdf',
      content_type: 'application/pdf',
      file_size: 1.megabyte,
    )
  end

  let(:document2) do
    instance_double(
      Document,
      s3_object_key: '321/abcdef1234',
      filename: 'test.csv',
      content_type: 'text/csv',
      file_size: 5.megabytes,
    )
  end

  let(:json_output) do
    [
      {
        s3_object_key: '123/abcdef1234',
        filename: 'test.pdf',
        content_type: 'application/pdf',
        file_size: 1.megabyte,
      },
      {
        s3_object_key: '321/abcdef1234',
        filename: 'test.csv',
        content_type: 'text/csv',
        file_size: 5.megabytes,
      },
    ].as_json
  end

  describe '#generate' do
    it { expect(subject).to eq(json_output) }
  end
end
