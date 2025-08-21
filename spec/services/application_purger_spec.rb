require 'rails_helper'

RSpec.describe ApplicationPurger do
  subject { described_class.call(crime_application:, deleted_by:, deletion_reason:) }

  let(:crime_application) { instance_double(CrimeApplication, id: '12345', reference: 10_000_001) }
  let(:deleted_by) { '1' }
  let(:deletion_reason) { DeletionReason::PROVIDER_ACTION.to_s }
  let(:documents) { [] }
  let(:document) { instance_double(Document) }

  before do
    allow(crime_application).to receive(:destroy!)

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
      expect(deletion_entry.record_id).to eq('12345')
      expect(deletion_entry.deleted_by).to eq('1')
      expect(deletion_entry.reason).to eq(DeletionReason::PROVIDER_ACTION.to_s)
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
        expect(crime_application).to receive(:destroy!)
        subject
      end
    end

    context 'when it does not have orphaned documents' do
      it 'does not try to delete s3 objects' do
        expect(Datastore::Documents::Delete).not_to receive(:new)
        subject
      end

      it 'purges the application from the local database' do
        expect(crime_application).to receive(:destroy!)
        subject
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
