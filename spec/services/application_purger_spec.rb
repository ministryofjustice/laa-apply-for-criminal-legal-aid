require 'rails_helper'

RSpec.describe ApplicationPurger do
  let(:crime_application) { instance_double(CrimeApplication) }
  let(:log_context) { LogContext.new(current_provider: Provider.new, ip_address: '123.123.123.123') }
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
    context 'when it has orphaned documents' do
      let(:documents) { [document] }
      let(:delete_double) { instance_double(Datastore::Documents::Delete, call: true) }

      before do
        allow(Datastore::Documents::Delete).to receive(:new).with(document:, log_context:).and_return(delete_double)
      end

      it 'deletes s3 objects' do
        expect(delete_double).to receive(:call)
        described_class.call(crime_application, log_context)
      end

      it 'purges the application from the local database' do
        expect(crime_application).to receive(:destroy!)
        described_class.call(crime_application, log_context)
      end
    end

    context 'when it does not have orphaned documents' do
      let(:documents) { [] }

      it 'does not try to delete s3 objects' do
        expect(Datastore::Documents::Delete).not_to receive(:new)
        described_class.call(crime_application, log_context)
      end

      it 'purges the application from the local database' do
        expect(crime_application).to receive(:destroy!)
        described_class.call(crime_application, log_context)
      end
    end
  end
end
