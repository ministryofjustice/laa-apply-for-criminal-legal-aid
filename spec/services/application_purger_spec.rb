require 'rails_helper'

RSpec.describe ApplicationPurger do
  let(:crime_application) { instance_double(CrimeApplication, submitted_at:) }

  let(:document) { instance_double(Document) }
  let(:submitted_at) { nil }

  before do
    allow(crime_application).to receive(:destroy!)

    # rubocop:disable RSpec/MessageChain
    allow(
      crime_application
    ).to receive_message_chain(:documents, :stored, :not_submitted).and_return(documents)
    # rubocop:enable RSpec/MessageChain
  end

  describe '.call' do
    context 'when application has a `submitted_at` timestamp' do
      let(:documents) { [document] }
      let(:submitted_at) { Time.current }

      it 'purges the application from the local database without deleting documents' do
        expect(Datastore::Documents::Delete).not_to receive(:new)
        expect(crime_application).to receive(:destroy!)
        described_class.call(crime_application)
      end
    end

    context 'when it has orphaned documents' do
      let(:documents) { [document] }
      let(:delete_double) { instance_double(Datastore::Documents::Delete, call: true) }

      before do
        allow(Datastore::Documents::Delete).to receive(:new).with(document:).and_return(delete_double)
      end

      it 'deletes s3 objects' do
        expect(delete_double).to receive(:call)
        described_class.call(crime_application)
      end

      it 'purges the application from the local database' do
        expect(crime_application).to receive(:destroy!)
        described_class.call(crime_application)
      end
    end

    context 'when it does not have orphaned documents' do
      let(:documents) { [] }

      it 'does not try to delete s3 objects' do
        expect(Datastore::Documents::Delete).not_to receive(:new)
        described_class.call(crime_application)
      end

      it 'purges the application from the local database' do
        expect(crime_application).to receive(:destroy!)
        described_class.call(crime_application)
      end
    end
  end
end
