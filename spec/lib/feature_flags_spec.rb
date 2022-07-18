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
          staging: true,
        },
        disabled_foobar_feature: {
          local: false,
          staging: false,
        }
      }.with_indifferent_access
    )
  end

  describe '#enabled?' do
    context 'test environment on local host' do
      it 'is enabled' do
        expect(FeatureFlags.enabled_foobar_feature.enabled?).to be true
        expect(FeatureFlags.enabled_foobar_feature.disabled?).to be false
      end
      it 'is disabled' do
        expect(FeatureFlags.disabled_foobar_feature.enabled?).to be false
        expect(FeatureFlags.disabled_foobar_feature.disabled?).to be true
      end
    end

    context 'development environment on local host' do
      before do
        allow(Rails).to receive(:env).and_return('development'.inquiry)
      end

      it 'is enabled' do
        expect(FeatureFlags.enabled_foobar_feature.enabled?).to be true
      end
      it 'is disabled' do
        expect(FeatureFlags.disabled_foobar_feature.enabled?).to be false
      end
    end

    context 'production environment on staging server' do
      before do
        allow(HostEnv).to receive(:env_name).and_return(HostEnv::STAGING)
      end

      it 'is enabled' do
        expect(FeatureFlags.enabled_foobar_feature.enabled?).to be true
      end
      it 'is disabled' do
        expect(FeatureFlags.disabled_foobar_feature.enabled?).to be false
      end
    end
  end

  describe 'handling of method_missing' do
    context 'a feature defined in the config' do
      it 'responds true' do
        expect(FeatureFlags.respond_to?(:enabled_foobar_feature)).to be true
      end
    end

    context 'a method defined on the superclass' do
      it 'responds true' do
        expect(FeatureFlags.respond_to?(:object_id)).to be true
      end
    end

    context 'unknown method' do
      it 'responds false' do
        expect(FeatureFlags.respond_to?(:not_a_real_feature)).to be false
      end

      it 'raises an exception' do
        expect { FeatureFlags.not_a_real_feature }.to raise_exception(NoMethodError)
      end
    end
  end
end
