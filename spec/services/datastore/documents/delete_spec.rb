require 'rails_helper'

RSpec.describe Datastore::Documents::Delete do
  subject {
    described_class.new(document: document, deleted_by: '1',
                        deletion_reason: DeletionReason::PROVIDER_ACTION.to_s)
  }

  let(:document) { instance_double(Document, submitted_at:, s3_object_key:, content_type:) }
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
      let(:crime_application) { instance_double(CrimeApplication, reference: '123') }

      before do
        stub_request(:delete, 'http://datastore-webmock/api/v1/documents/MTIzL2FiY2RlZjEyMzQ=')
          .to_return(status: 200, body: '{"object_key":"123/abcdef1234"}')

        allow(document).to receive_messages(id: 'd9e31559', crime_application_id: 'b32a70f86e2')
        allow(CrimeApplication).to receive(:find).with('b32a70f86e2').and_return(crime_application)
      end

      it 'returns true' do
        expect(subject.call).to be(true)
      end

      it 'stores deletion entry' do
        subject.call

        deletion_entry = DeletionEntry.first
        expect(deletion_entry.record_id).to eq('d9e31559')
        expect(deletion_entry.record_type).to eq(RecordType::DOCUMENT.to_s)
        expect(deletion_entry.business_reference).to eq('123')
        expect(deletion_entry.reason).to eq(DeletionReason::PROVIDER_ACTION.to_s)
      end
    end

    context 'when a document is not deleted successfully' do
      before do
        stub_request(:delete, 'http://datastore-webmock/api/v1/documents/MTIzL2FiY2RlZjEyMzQ=')
          .to_return(status: 500, body: '')
      end

      it 'returns false' do
        expect(document).not_to receive(:destroy)
        expect(subject.call).to be(false)
      end
    end
  end
end
