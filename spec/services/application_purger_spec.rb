require 'rails_helper'

RSpec.describe ApplicationPurger do
  let(:crime_application) { instance_double(CrimeApplication, id: '12345', reference: 10_000_001) }
  let(:log_context) { LogContext.new(current_provider: current_provider, ip_address: '123.123.123.123') }
  let(:current_provider) { instance_double(Provider, id: 1) }
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
      expect do
        described_class.call(crime_application, log_context, current_provider)
      end.to change(DeletionEntry, :count).by(1)

      deletion_entry = DeletionEntry.first
      expect(deletion_entry.record_id).to eq('12345')
      expect(deletion_entry.deleted_by).to eq('1')
      expect(deletion_entry.reason).to eq(DeletionReason::PROVIDER_ACTION.to_s)
    end

    context 'when it has orphaned documents' do
      let(:documents) { [document] }
      let(:delete_double) { instance_double(Datastore::Documents::Delete, call: true) }

      before do
        allow(Datastore::Documents::Delete).to receive(:new).with(document:, log_context:, current_provider:).and_return(delete_double)
      end

      it 'deletes s3 objects' do
        expect(delete_double).to receive(:call)
        described_class.call(crime_application, log_context, current_provider)
      end

      it 'purges the application from the local database' do
        expect(crime_application).to receive(:destroy!)
        described_class.call(crime_application, log_context, current_provider)
      end
    end

    context 'when it does not have orphaned documents' do
      it 'does not try to delete s3 objects' do
        expect(Datastore::Documents::Delete).not_to receive(:new)
        described_class.call(crime_application, log_context, current_provider)
      end

      it 'purges the application from the local database' do
        expect(crime_application).to receive(:destroy!)
        described_class.call(crime_application, log_context, current_provider)
      end
    end

    context 'when current_provider is nil' do
      let(:current_provider) { nil }

      it 'logs the deletion reason as system automated' do
        described_class.call(crime_application, log_context, current_provider)

        deletion_entry = DeletionEntry.first
        expect(deletion_entry.deleted_by).to eq('system_automated')
        expect(deletion_entry.reason).to eq(DeletionReason::RETENTION_RULE.to_s)
      end
    end
  end
end
