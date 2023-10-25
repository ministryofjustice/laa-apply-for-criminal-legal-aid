require 'rails_helper'

RSpec.describe Datastore::Documents::Delete do
  subject { described_class.new(document:, current_provider:, request_ip:) }

  let(:document) { instance_double(Document, submitted_at:, s3_object_key:, content_type:) }
  let(:current_provider) { Provider.new }
  let(:request_ip) { '123.123.123.123' }
  let(:submitted_at) { nil }
  let(:s3_object_key) { '123/abcdef1234' }
  let(:content_type) { 'application/pdf' }

  describe '#call' do
    context 'when document has already been submitted to case workers' do
      let(:submitted_at) { Date.yesterday }

      it 'returns true' do
        expect(subject.call).to be(true)
      end
    end

    context 'when document is not stored' do
      let(:s3_object_key) { nil }

      it 'returns true' do
        expect(subject.call).to be(true)
      end
    end

    context 'when a document is deleted successfully' do
      before do
        stub_request(:delete, 'http://datastore-webmock/api/v1/documents/MTIzL2FiY2RlZjEyMzQ=')
          .to_return(status: 200, body: '{"object_key":"123/abcdef1234"}')
      end

      it 'returns true' do
        expect(subject.call).to be(true)
      end
    end

    context 'when a document is not deleted successfully' do
      before do
        stub_request(:delete, 'http://datastore-webmock/api/v1/documents/MTIzL2FiY2RlZjEyMzQ=')
          .to_return(status: 500, body: '')
      end

      it 'returns false' do
        expect(subject.call).to be(false)
      end
    end
  end
end
