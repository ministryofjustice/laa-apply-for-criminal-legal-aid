require 'rails_helper'

RSpec.describe Datastore::Documents::Scan do
  subject { described_class.new(document:) }

  include_context 'with an existing document'

  describe '#call' do
    before do
      subject.document.tempfile = file
    end

    context 'when anti-virus server available' do
      before do
        allow(subject).to receive('unavailable?').and_return(false)
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
          expect(subject.flagged?).to be false
          expect(subject.inconclusive?).to be false
        end
      end

      context 'with an unsafe file' do
        before { expect(Clamby).to receive(:safe?).and_return(false) }

        it 'returns false' do
          expect(subject.call).to be false
          expect(subject.document.scan_status).to eq 'flagged'
          expect(subject.flagged?).to be true
          expect(subject.inconclusive?).to be false
        end
      end

      context 'with a missing virus scanner' do
        before { expect(Clamby).to receive(:safe?).and_raise(StandardError) }

        it 'returns false' do
          expect(subject.call).to be false
          expect(subject.document.scan_status).to eq 'incomplete'
        end
      end

      context 'with an inconclusive result' do
        before { expect(Clamby).to receive(:safe?).and_return(nil) }

        it 'returns false' do
          expect(subject.call).to be false
          expect(subject.document.scan_status).to eq 'other'
        end
      end

      context 'with a missing document' do
        it 'raises exception' do
          expect { described_class.new(document: nil).call }.to raise_error ArgumentError
        end
      end

      context 'with remote anti-virus server timeout' do
        before do
          allow(Timeout).to receive(:timeout).and_raise(Timeout::Error)
        end

        it 'returns true' do
          expect(subject.call).to be false
          expect(subject.document.scan_status).to eq 'incomplete'
        end
      end
    end

    context 'when anti-virus server unavailable' do
      before do
        allow(subject).to receive('unavailable?').and_return(true)
      end

      it 'sets scan status to `other`' do
        subject.call
        document.reload

        expect(subject.document.scan_at).to be_a Time
        expect(subject.document.scan_status).to eq 'other'
        expect(subject.document.scan_provider).to eq 'ClamAV'
      end
    end
  end

  describe '#unavailable?' do
    before do
      allow(Open3).to receive(:capture3).and_call_original
    end

    let(:status) do
      instance_double(Process::Status, success?: true, exitstatus: 0)
    end

    context 'when clamdscan is not installed' do
      subject { described_class.new(document:).unavailable? }

      before do
        allow(Open3)
          .to receive(:capture3)
          .with(/clamdscan/, any_args)
          .and_raise(Errno::ENOENT, 'No such file or directory - clamdscan')

        allow(Rails.logger).to receive(:error).with(/ClamAV Scan Error - clamdscan package must be installed/)
      end

      it { expect(subject).to be true }

      it 'logs errors' do
        subject

        expect(Rails.logger).to have_received(:error).with(/ClamAV Scan Error - clamdscan package must be installed/)
      end
    end

    context 'when clamdscan is installed but remote server unreachable' do
      subject { described_class.new(document:).unavailable? }

      before do
        stdout = "ClamAV 1.2.1\n"
        stderr = "ERROR: Could not connect to clamd on localhost: Connection refused\n"

        allow(Open3)
          .to receive(:capture3)
          .with(/clamdscan/, any_args)
          .and_return([stdout, stderr, status])
      end

      it { expect(subject).to be true }
    end

    context 'when clamdscan is installed and remote server reachable' do
      subject { described_class.new(document:).unavailable? }

      before do
        stdout = "ClamAV 1.1.0/27039/Fri Sep 22 07:38:03 2023\n"
        stderr = ''

        allow(Open3)
          .to receive(:capture3)
          .with(/clamdscan/, any_args)
          .and_return([stdout, stderr, status])
      end

      it { expect(subject).to be false }
    end
  end
end
