require 'rails_helper'

RSpec.describe Datastore::Documents::Upload do
  subject { described_class.new(document:, current_provider:, request_ip:) }

  include_context 'with an existing document'

  let(:current_provider) { Provider.new }
  let(:request_ip) { '123.123.123.123' }
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
      end

      it 'has `awaiting` virus scan status before upload' do
        expect(subject.document.scan_status).to eq 'awaiting'
        expect(subject.document.scan_at).to be_nil
        expect(subject.document.scan_provider).to be_nil
        expect(subject.document.scan_output).to be_nil
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

    # Requires further consideration for handling unsafe file journey
    context 'when document has malicious virus' do
      before do
        allow(Clamby).to receive(:safe?).and_return(false)

        stub_request(:put, 'http://datastore-webmock/api/v1/documents/presign_upload')
          .with(body: expected_query)
          .to_return(status: 201, body: { object_key: '123/abcdef1234', url: presign_upload_url }.to_json)

        stub_request(:put, presign_upload_url)
          .to_return(status: 200)
      end

      it 'continues upload' do
        expect(subject.call).to be(true)
      end
    end
  end
end
