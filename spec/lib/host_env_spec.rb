require 'rails_helper'

describe HostEnv do
  describe 'local machine environment' do
    context 'local development rails environment' do
      before do
        allow(Rails.env).to receive_messages(development?: true, test?: false)
      end

      describe '.staging?' do
        it 'returns false' do
          expect(described_class.staging?).to be false
        end
      end

      describe '.production?' do
        it 'returns false' do
          expect(described_class.production?).to be false
        end
      end

      describe '.local?' do
        it 'returns true' do
          expect(described_class.local?).to be true
        end
      end

      describe '.test?' do
        it 'returns false' do
          expect(described_class.test?).to be false
        end
      end
    end

    context 'local test rails environment' do
      describe '.staging?' do
        it 'returns false' do
          expect(described_class.staging?).to be false
        end
      end

      describe '.production?' do
        it 'returns true' do
          expect(described_class.production?).to be false
        end
      end

      describe '.local?' do
        it 'returns false' do
          expect(described_class.local?).to be false
        end
      end

      describe '.test?' do
        it 'returns true' do
          expect(described_class.test?).to be true
        end
      end
    end
  end

  describe 'ENV_NAME variable is set in production envs' do
    before do
      allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('production'))
      allow(ENV).to receive(:fetch).with('ENV_NAME').and_return(env_name)
    end

    context 'staging host' do
      let(:env_name) { HostEnv::STAGING }

      it { expect(described_class.local?).to be(false) }
      it { expect(described_class.staging?).to be(true) }
      it { expect(described_class.production?).to be(false) }
    end

    context 'production host' do
      let(:env_name) { HostEnv::PRODUCTION }

      it { expect(described_class.local?).to be(false) }
      it { expect(described_class.staging?).to be(false) }
      it { expect(described_class.production?).to be(true) }
    end

    context 'unknown host' do
      let(:env_name) { 'foobar' }

      it { expect(described_class.local?).to be(false) }
      it { expect(described_class.staging?).to be(false) }
      it { expect(described_class.production?).to be(false) }
    end
  end

  describe 'when is a production env and the ENV_NAME variable is not set' do
    before do
      allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('production'))
    end

    it 'raises an exception so we are fully aware' do
      expect do
        described_class.production?
      end.to raise_exception(KeyError)
    end
  end
end
