require 'rails_helper'

describe FeatureSet do

  before(:each) do
    # override whatever is in the settings file with these settings
    Settings.enabled_features.test_on = Config::Options.new({
                                                             :"Local" => true,
                                                             :"Host-staging" => true,
                                                         })

    Settings.enabled_features.test_off = Config::Options.new({
                                                             :"Local" => false,
                                                             :"Host-staging" => false,
                                                         })
  end

  before(:each) { @saved_env = ENV['ENV'] }

  after(:each)  { ENV['ENV'] = @saved_env }

  describe '#enabled?' do
    context 'test environment on local host' do
      it 'is enabled' do
        expect(FeatureSet.test_on.enabled?).to be true
      end
      it 'is disabled' do
        expect(FeatureSet.test_off.enabled?).to be false
      end
    end

    context 'development environment on local host' do
      it 'is enabled' do
        expect(Rails.env).to receive(:development?).and_return(true)
        expect(FeatureSet.test_on.enabled?).to be true
      end
      it 'is disabled' do
        expect(Rails.env).to receive(:development?).and_return(true)
        expect(FeatureSet.test_off.enabled?).to be false
      end
    end

    context 'production environment on staging server' do
      it 'is enabled' do
        ENV['ENV'] = 'staging'
        expect(FeatureSet.test_on.enabled?).to be true
      end

      it 'is disabled' do
        ENV['ENV'] = 'staging'
        expect(FeatureSet.test_off.enabled?).to be false
      end
    end
  end

  describe '#enable!' do
    context 'on an environment where it is disabled' do
      it 'is enabled' do
        ENV['ENV'] = 'staging'
        expect(FeatureSet.test_off.enabled?).to be false
        FeatureSet.test_off.enable!
        expect(FeatureSet.test_off.enabled?).to be true
      end
    end
  end

  describe '#disable!' do
    context 'on an environment where it is enabled' do
      it 'is disabled' do
        ENV['ENV'] = 'staging'
        expect(FeatureSet.test_on.enabled?).to be true
        FeatureSet.test_on.disable!
        expect(FeatureSet.test_on.enabled?).to be false
      end
    end
  end

  describe '#respond_to?' do
    context 'a feature defined in the config' do
      it 'responds true' do
        expect(FeatureSet.respond_to?(:test_on)).to be true
      end
    end

    context 'a method defined on the superclass' do
      it 'responds true' do
        expect(FeatureSet.respond_to?(:object_id)).to be true
      end
    end

    context 'unknown method' do
      it 'responds false' do
        expect(FeatureSet.respond_to?(:not_in_config)).to be false
      end
    end
  end
end
