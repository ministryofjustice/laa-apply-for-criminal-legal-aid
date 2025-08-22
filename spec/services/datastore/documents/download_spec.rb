require 'rails_helper'

RSpec.describe Datastore::Documents::Download do
  subject { described_class.new(document:) }

  let(:document) { instance_double(Document, s3_object_key:, content_type:, filename:) }
  let(:s3_object_key) { '123/abcdef1234' }
  let(:content_type) { 'application/pdf' }
  let(:filename) { 'bankstatement.pdf' }
  let(:expected_query) do
    { object_key: %r{123/.*}, s3_opts: { expires_in: Datastore::Documents::Download::PRESIGNED_URL_EXPIRES_IN,
                                         response_content_disposition:  "attachment; filename=\"#{filename}\"" } }
  end

  describe '#call' do
    context 'when a document exists' do
      before do
        stub_request(:put, 'http://datastore-webmock/api/v1/documents/presign_download')
          .with(body: expected_query)
          .to_return(status: 200, body: '{"object_key":"123/abcdef1234", "url":"https://secure.com/123/abcdef1234?fileinfo"}')
      end

      it 'returns DocumentResult' do
        result = subject.call

        expect(result).to be_a DatastoreApi::Responses::DocumentResult
        expect(result.url).to be_present
      end
    end

    context 'when a document does not exist' do
      before do
        stub_request(:put, 'http://datastore-webmock/api/v1/documents/presign_download')
          .to_return(status: 404, body: '{}')
      end

      it 'returns false' do
        result = subject.call

        expect(result).to be false
      end
    end
  end
end
