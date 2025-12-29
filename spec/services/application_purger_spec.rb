require 'rails_helper'

RSpec.describe ApplicationPurger do
  subject { described_class.call(crime_application:, deleted_by:, deletion_reason:) }

  let(:crime_application) {
    CrimeApplication.create!(reference: 10_000_001, application_type: ApplicationType::INITIAL)
  }
  let(:deleted_by) { '1' }
  let(:deletion_reason) { DeletionReason::PROVIDER_ACTION.to_s }
  let(:documents) { [] }
  let(:document) { instance_double(Document) }

  before do
    # rubocop:disable RSpec/MessageChain
    allow(
      crime_application
    ).to receive_message_chain(:documents, :stored, :not_submitted).and_return(documents)
    # rubocop:enable RSpec/MessageChain
  end

  describe '.call' do
    it 'logs the deletion' do
      expect { subject }.to change(DeletionEntry, :count).by(1)

      deletion_entry = DeletionEntry.first
      expect(deletion_entry.record_id).to eq(crime_application.id)
      expect(deletion_entry.deleted_by).to eq('1')
      expect(deletion_entry.reason).to eq(DeletionReason::PROVIDER_ACTION.to_s)
    end

    it 'makes a request to publish a draft deletion event' do
      subject
      expect(WebMock).to have_requested(:post, 'http://datastore-webmock/api/v1/applications/draft_deleted')
        .with(body: hash_including(
          'entity_id' => crime_application.id,
          'entity_type' => crime_application.application_type.to_s,
          'business_reference' => crime_application.reference,
          'reason' => deletion_reason,
          'deleted_by' => deleted_by,
        ))
    end

    context 'when the Datastore API fails on deletion' do
      before do
        stub_request(:post, 'http://datastore-webmock/api/v1/applications/draft_deleted')
          .to_return(status: 500, body: '{}', headers: {})
      end

      it 'rolls back the transaction' do
        expect {
          subject
        }.to(raise_error(DatastoreApi::Errors::ServerError)
         .and(not_change(CrimeApplication, :count))
         .and(not_change(DeletionEntry, :count)))
      end
    end

    context 'when it has orphaned documents' do
      let(:documents) { [document] }
      let(:delete_double) { instance_double(Datastore::Documents::Delete, call: true) }

      before do
        allow(Datastore::Documents::Delete).to receive(:new).with(document:, deleted_by:,
                                                                  deletion_reason:).and_return(delete_double)
      end

      it 'deletes s3 objects' do
        expect(delete_double).to receive(:call)
        subject
      end

      it 'purges the application from the local database' do
        expect { subject }.to change(CrimeApplication, :count).from(1).to(0)
      end
    end

    context 'when it does not have orphaned documents' do
      it 'does not try to delete s3 objects' do
        expect(Datastore::Documents::Delete).not_to receive(:new)
        subject
      end

      it 'purges the application from the local database' do
        expect { subject }.to change(CrimeApplication, :count).from(1).to(0)
      end
    end

    context 'when current_provider is nil' do
      let(:deleted_by) { 'system_automated' }
      let(:deletion_reason) { DeletionReason::RETENTION_RULE.to_s }

      it 'logs the deletion reason as system automated' do
        subject

        deletion_entry = DeletionEntry.first
        expect(deletion_entry.deleted_by).to eq('system_automated')
        expect(deletion_entry.reason).to eq(DeletionReason::RETENTION_RULE.to_s)
      end
    end
  end
end
