require 'rails_helper'

describe FeatureFlags do
  before do
    # override whatever is in the settings file with these settings
    # so that tests are predictable
    allow(
      described_class.instance
    ).to receive(:config).and_return(
      {
        enabled_foobar_feature: {
          local: true,
          test: true,
          staging: true,
        },
        disabled_foobar_feature: {
          local: false,
          test: false,
          staging: false,
        },
        feature_lacking_some_envs: {
          production: true,
        }
      }.with_indifferent_access
    )
  end

  describe '#enabled?' do
    context 'test environment on local host' do
      it 'has the expected HostEnv' do
        expect(described_class.instance.env_name).to eq(HostEnv::TEST)
      end

      it 'is enabled' do
        expect(described_class.enabled_foobar_feature.enabled?).to be true
        expect(described_class.enabled_foobar_feature.disabled?).to be false
      end

      it 'is disabled' do
        expect(described_class.disabled_foobar_feature.enabled?).to be false
        expect(described_class.disabled_foobar_feature.disabled?).to be true
      end

      it 'defaults to true when test env is not declared' do
        expect(described_class.feature_lacking_some_envs.enabled?).to be true
      end
    end

    context 'development environment on local host' do
      before do
        allow(
          described_class.instance
        ).to receive(:env_name).and_return(HostEnv::LOCAL)
      end

      it 'has the expected HostEnv' do
        expect(described_class.instance.env_name).to eq(HostEnv::LOCAL)
      end

      it 'is enabled' do
        expect(described_class.enabled_foobar_feature.enabled?).to be true
      end

      it 'is disabled' do
        expect(described_class.disabled_foobar_feature.enabled?).to be false
      end

      it 'defaults to true when local env is not declared' do
        expect(described_class.feature_lacking_some_envs.enabled?).to be true
      end
    end

    context 'production environment on staging server' do
      before do
        allow(
          described_class.instance
        ).to receive(:env_name).and_return(HostEnv::STAGING)
      end

      it 'has the expected HostEnv' do
        expect(described_class.instance.env_name).to eq(HostEnv::STAGING)
      end

      it 'is enabled' do
        expect(described_class.enabled_foobar_feature.enabled?).to be true
      end

      it 'is disabled' do
        expect(described_class.disabled_foobar_feature.enabled?).to be false
      end

      it 'for an env not declared, defaults to false' do
        expect(described_class.feature_lacking_some_envs.enabled?).to be false
      end
    end
  end

  describe 'handling of method_missing' do
    context 'a feature defined in the config' do
      it 'responds true' do
        expect(described_class.respond_to?(:enabled_foobar_feature)).to be true
      end
    end

    context 'a method defined on the superclass' do
      it 'responds true' do
        expect(described_class.respond_to?(:object_id)).to be true
      end
    end

    context 'unknown method' do
      it 'responds false' do
        expect(described_class.respond_to?(:not_a_real_feature)).to be false
      end

      it 'raises an exception' do
        expect { described_class.not_a_real_feature }.to raise_exception(NoMethodError)
      end
    end
  end
end
