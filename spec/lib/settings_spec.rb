require 'rails_helper'

describe Settings do
  before do
    # override whatever is in the settings file with these settings
    # so that tests are predictable
    allow(
      described_class.instance
    ).to receive(:config).and_return(
      { my_test_setting: 'hello' }.with_indifferent_access
    )
  end

  describe 'reading settings' do
    it { expect(described_class.my_test_setting).to eq('hello') }
  end

  describe 'handling of method_missing' do
    context 'a setting defined in the config' do
      it 'responds true' do
        expect(described_class.respond_to?(:my_test_setting)).to be(true)
      end
    end

    context 'a method defined on the superclass' do
      it 'responds true' do
        expect(described_class.respond_to?(:object_id)).to be(true)
      end
    end

    context 'unknown setting' do
      it 'responds false' do
        expect(described_class.respond_to?(:not_a_real_setting)).to be(false)
      end

      it 'raises an exception' do
        expect { described_class.not_a_real_setting }.to raise_exception(NoMethodError)
      end
    end
  end
end
