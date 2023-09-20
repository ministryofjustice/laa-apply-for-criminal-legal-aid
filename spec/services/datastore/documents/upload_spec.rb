require 'rails_helper'

RSpec.describe Datastore::Documents::Upload do
  subject { described_class.new(document:) }

  include_context 'with an existing document'

  let(:expected_query) do
    { object_key: %r{123/.*}, s3_opts: { expires_in: 15 } }
  end

  let(:presign_upload_url) do
    'https://localhost.localstack.cloud:4566/crime-apply-documents-dev/2/r95W71G1hz?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=test%2F20230910%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230910T092836Z&X-Amz-Expires=15&X-Amz-SignedHeaders=host&X-Amz-Signature=462682cb716e7e368cbacf2d36203a85fd27835200bb28fc2813e19311333a36'
  end

  describe '#call' do
    context 'when a document is uploaded successfully' do
      before do
        stub_request(:put, 'http://datastore-webmock/api/v1/documents/presign_upload')
          .with(body: expected_query)
          .to_return(status: 201, body: { object_key: '123/abcdef1234', url: presign_upload_url }.to_json)

        stub_request(:put, presign_upload_url)
          .to_return(status: 200)

        allow(subject).to receive(:virus_scan!).and_return(true)
      end

      it 'returns true and updates the documents s3 object key' do
        expect(subject.call).to be(true)
        expect(subject.document.s3_object_key).to eq('123/abcdef1234')
      end
    end

    context 'when there is a problem connecting to the API' do
      before do
        stub_request(:put, 'http://datastore-webmock/api/v1/documents/presign_upload')
          .with(body: expected_query)
          .to_return(status: 500)
      end

      it 'returns false' do
        expect(subject.call).to be(false)
      end
    end

    context 'when there is a problem uploading to s3' do
      before do
        stub_request(:put, 'http://datastore-webmock/api/v1/documents/presign_upload')
          .with(body: expected_query)
          .to_return(status: 201, body: { object_key: '123/abcdef1234', url: presign_upload_url }.to_json)

        stub_request(:put, presign_upload_url)
          .to_return(status: 500)
      end

      it 'returns false' do
        expect(subject.call).to be(false)
      end
    end

    context 'when a document has previously been saved' do
      let(:attributes) { super().merge(s3_object_key: '123/abcdef1234') }

      it 'returns false' do
        expect(subject.call).to be(false)
      end
    end
  end

  # Cursory testing of the virus_scan method rather than the actual clam_scan library
  # which has a dependency on the clamdscan daemon or clamscan executable
  describe '#virus_scan!' do
    context 'with no file' do
      subject { described_class.new(document: nil) }

      it 'throws UnsuccessfulUploadError exception' do
        expect {
          subject.send(:virus_scan!)
        }.to raise_exception Datastore::Documents::Upload::UnsuccessfulUploadError, 'File not found'
      end
    end

    context 'with a compromised file' do
      subject { described_class.new(document: Document.new(tempfile: Tempfile.new('badfile.txt'))) }

      before do
        allow_any_instance_of(ClamScan::Response).to receive(:virus?).and_return(true)
      end

      it 'returns false and logs the error' do
        expect(Rails.logger).to receive(:error).with(/File may be unsafe. ClamAV Result:/)
        subject.send(:virus_scan!)
      end
    end

    context 'with a valid file' do
      subject { described_class.new(document: Document.new(tempfile: Tempfile.new('okfile.txt'))) }

      it { expect(subject.send(:virus_scan!)).to be true }
    end
  end
end
