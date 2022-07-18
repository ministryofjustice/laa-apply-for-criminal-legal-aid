require 'rails_helper'

describe HostEnv do
  describe 'local machine environment' do
    context 'local development rails environment' do
      before do
        allow(Rails.env).to receive(:development?).and_return(true)
      end

      describe 'HostEnv.staging?' do
        it 'returns false' do
          expect(HostEnv.staging?).to be false
        end
      end

      describe 'HostEnv.production?' do
        it 'returns false' do
          expect(HostEnv.production?).to be false
        end
      end

      describe '.local?' do
        it 'returns true' do
          expect(HostEnv.local?).to be true
        end
      end
    end

    context 'local test rails environment' do
      describe 'HostEnv.staging?' do
        it 'returns false' do
          expect(HostEnv.staging?).to be false
        end
      end

      describe '.production?' do
        it 'returns true' do
          expect(HostEnv.production?).to be false
        end
      end

      describe '.local?' do
        it 'returns true' do
          expect(HostEnv.local?).to be true
        end
      end
    end
  end

  describe 'ENV_NAME variable is set in production envs' do
    before do
      allow(Rails).to receive(:env).and_return('production'.inquiry)
      allow(ENV).to receive(:fetch).with('ENV_NAME').and_return(env_name)
    end

    context 'staging host' do
      let(:env_name) { HostEnv::STAGING }

      it { expect(HostEnv.local?).to eq(false) }
      it { expect(HostEnv.staging?).to eq(true) }
      it { expect(HostEnv.production?).to eq(false) }
    end

    context 'production host' do
      let(:env_name) { HostEnv::PRODUCTION }

      it { expect(HostEnv.local?).to eq(false) }
      it { expect(HostEnv.staging?).to eq(false) }
      it { expect(HostEnv.production?).to eq(true) }
    end

    context 'unknown host' do
      let(:env_name) { 'foobar' }

      it { expect(HostEnv.local?).to eq(false) }
      it { expect(HostEnv.staging?).to eq(false) }
      it { expect(HostEnv.production?).to eq(false) }
    end
  end

  describe 'when is a production env and the ENV_NAME variable is not set' do
    before do
      allow(Rails).to receive(:env).and_return('production'.inquiry)
    end

    it 'raises an exception so we are fully aware' do
      expect {
        HostEnv.production?
      }.to raise_exception(KeyError)
    end
  end
end
