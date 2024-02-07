require 'rails_helper'

RSpec.describe Type::Money do
  subject(:money) { described_class.new }

  describe 'registry' do
    it 'is registered with ActiveModel type `:money`' do
      expect(
        ActiveModel::Type.lookup(:money).is_a?(described_class)
      ).to be(true)
    end

    it 'has an underlying type of `:money`' do
      expect(subject.type).to eq(:money)
    end
  end

  describe '#serialize' do
    subject(:serialized_value) { money.serialize(value) }

    describe 'when value is `nil`' do
      let(:value) { 0 }

      it { is_expected.to eq(0) }
    end

    describe 'when value is a float' do
      let(:value) { 1.23109923 }

      it { is_expected.to eq(123) }
    end

    describe 'when value is a string' do
      let(:value) { '321.019' }

      it { is_expected.to eq(32_102) }

      it { is_expected.to be_a(Integer) }
    end

    describe 'when value is an integer' do
      let(:value) { 123 }

      it { is_expected.to eq(12_300) }
    end
  end

  describe '#deserialize(value)' do
    subject(:deserialized_value) { money.deserialize(value) }

    describe 'when value is `nil`' do
      let(:value) { nil }

      it { is_expected.to be_nil }
    end

    describe 'when value is `empty`' do
      let(:value) { '' }

      it { is_expected.to be_nil }
    end

    describe 'when value is a float' do
      let(:value) { 1100 }

      it { is_expected.to eq(11.0) }

      it { is_expected.to be_a(Float) }
    end
  end

  describe '#cast(value)' do
    subject(:coerced_value) { money.cast(value) }

    describe 'when value is `nil`' do
      let(:value) { nil }

      it { is_expected.to be_nil }
    end

    describe 'when value is a float' do
      let(:value) { 1.23 }

      it { is_expected.to eq('1.23') }
    end

    describe 'when value is a string' do
      let(:value) { '321.01' }

      it { is_expected.to eq('321.01') }
    end

    describe 'when value is an integer' do
      let(:value) { 123 }

      it { is_expected.to eq(123) }
    end
  end
end
