require 'rails_helper'

describe HostEnv do
  describe 'local machine environment' do
    context 'local development rails environment' do
      before(:each) do
        ENV['RAILS_ENV'] = 'development'
      end

      after(:each) do
        ENV['RAILS_ENV'] = 'test'
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

      describe '.test?' do
        it 'returns true' do
          expect(HostEnv.test?).to be true
        end
      end

      describe '.local?' do
        it 'returns true' do
          expect(HostEnv.local?).to be true
        end
      end
    end
  end

  describe 'Cloud Platform infrastructure environments' do
    before(:each) do
      k8s_settings = YAML.load_file("config/kubernetes/#{namespace}/config_map.yml")
      @envvars = k8s_settings.dig('data')
    end

    context 'Staging server' do
      let(:namespace) { 'staging' }

      before(:each) do
        ENV['ENV'] = 'staging'
        ENV['RACK_ENV'] = 'production'
        ENV['RAILS_ENV'] = 'production'
      end

      after(:each) do
        ENV['ENV'] = nil
        ENV['RACK_ENV'] = nil
        ENV['RAILS_ENV'] = 'test'
      end

      it 'is a staging server environment' do
        expect(HostEnv.staging?).to be true
        expect_k8s_settings
      end

      it 'is not another environment' do
        expect(HostEnv.local?).to be false
        expect(HostEnv.production?).to be false
      end

      def expect_k8s_settings
        expect(@envvars['ENV']).to eq ENV['ENV']
        expect(@envvars['RACK_ENV']).to eq ENV['RACK_ENV']
        expect(@envvars['RAILS_ENV']).to eq ENV['RAILS_ENV']
      end
    end
  end
end
