require 'rails_helper'

RSpec.describe Type::StrippedString do
  subject { described_class.new }

  let(:coerced_value) { subject.cast(value) }

  describe 'registry' do
    it 'is registered with type `:string`' do
      expect(
        ActiveModel::Type.lookup(:string).is_a?(described_class)
      ).to be(true)
    end

    it 'has an underlying type of `:string`' do
      expect(subject.type).to eq(:string)
    end
  end

  describe 'when value is `nil`' do
    let(:value) { nil }

    it { expect(coerced_value).to be_nil }
  end

  describe 'when value is a symbol' do
    let(:value) { :foobar }

    it { expect(coerced_value).to eq('foobar') }
  end

  describe 'when value is numeric' do
    let(:value) { 123 }

    it { expect(coerced_value).to eq('123') }
  end

  describe 'when value is true' do
    let(:value) { true }

    it { expect(coerced_value).to eq('t') }
    it { expect(coerced_value.frozen?).to be(true) }
  end

  describe 'when value is false' do
    let(:value) { false }

    it { expect(coerced_value).to eq('f') }
    it { expect(coerced_value.frozen?).to be(true) }
  end

  describe 'strip spaces from the string value' do
    context 'no lead or trail spaces' do
      let(:value) { 'foobar' }

      it { expect(coerced_value).to eq('foobar') }
    end

    context 'leading spaces' do
      let(:value) { ' foobar' }

      it { expect(coerced_value).to eq('foobar') }
    end

    context 'trailing spaces' do
      let(:value) { 'foobar ' }

      it { expect(coerced_value).to eq('foobar') }
    end

    context 'leading and trailing spaces' do
      let(:value) { ' foobar ' }

      it { expect(coerced_value).to eq('foobar') }
    end

    context 'more than one leading or trailing spaces' do
      let(:value) { '   foobar   ' }

      it { expect(coerced_value).to eq('foobar') }
    end

    describe 'intermediate spaces' do
      let(:value) { ' foo bar ' }

      it { expect(coerced_value).to eq('foo bar') }
    end

    describe 'more than one intermediate spaces' do
      let(:value) { ' foo   bar ' }

      it { expect(coerced_value).to eq('foo   bar') }
    end
  end
end
