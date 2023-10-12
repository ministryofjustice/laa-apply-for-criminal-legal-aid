require 'rails_helper'

RSpec.describe Datastore::Documents::Scan do
  subject { described_class.new(document:) }

  include_context 'with an existing document'

  describe '#call' do
    before do
      subject.document.tempfile = file
    end

    context 'with any document' do
      before { expect(Clamby).to receive(:safe?).and_return(false) }

      it 'persists virus scan attributes' do
        subject.call
        document.reload

        expect(subject.document.scan_at).to be_a Time
        expect(subject.document.scan_status).to be_present
        expect(subject.document.scan_provider).to eq 'ClamAV'
      end
    end

    context 'with a safe file' do
      before { expect(Clamby).to receive(:safe?).and_return(true) }

      it 'returns true' do
        expect(subject.call).to be true
        expect(subject.document.scan_status).to eq 'pass'
      end
    end

    context 'with an unsafe file' do
      before { expect(Clamby).to receive(:safe?).and_return(false) }

      it 'returns false' do
        expect(subject.call).to be false
        expect(subject.document.scan_status).to eq 'flagged'
      end
    end

    context 'with a missing virus scanner' do
      before { expect(Clamby).to receive(:safe?).and_raise(StandardError) }

      it 'returns false' do
        expect(subject.call).to be false
        expect(subject.document.scan_status).to eq 'incomplete'
      end
    end

    context 'with an undetermined result' do
      before { expect(Clamby).to receive(:safe?).and_return(nil) }

      it 'returns false' do
        expect(subject.call).to be false
        expect(subject.document.scan_status).to eq 'other'
      end
    end

    context 'with a missing document' do
      it 'returns false' do
        expect { described_class.new(document: nil).call }.to raise_error ArgumentError
      end
    end
  end
end
