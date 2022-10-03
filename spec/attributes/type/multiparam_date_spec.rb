require 'rails_helper'

RSpec.describe Type::MultiparamDate do
  subject { described_class.new }

  let(:coerced_value) { subject.cast(value) }

  describe 'registry' do
    it 'is registered with type `:multiparam_date`' do
      expect(
        ActiveModel::Type.lookup(:multiparam_date).is_a?(described_class)
      ).to be(true)
    end

    it 'has an underlying type of `:date`' do
      expect(subject.type).to eq(:date)
    end
  end

  describe 'when value is `nil`' do
    let(:value) { nil }

    it { expect(coerced_value).to be_nil }
  end

  describe 'when value is already a date' do
    let(:value) { Date.yesterday }

    it { expect(coerced_value).to eq(value) }
  end

  describe 'when value is a multi parameter hash' do
    let(:date) { Date.new(2008, 11, 22) }

    context 'and contains all needed parts' do
      let(:value) { { 3 => date.day, 2 => date.month, 1 => date.year } }

      it { expect(coerced_value).to eq(date) }
    end

    context 'the parts do not represent a valid date (invalid month)' do
      let(:value) { { 3 => date.day, 2 => 13, 1 => date.year } }

      it { expect(coerced_value).to eq(value) }
    end

    context 'the parts do not represent a valid date (invalid day)' do
      let(:value) { { 3 => 32, 2 => date.month, 1 => date.year } }

      it { expect(coerced_value).to eq(value) }
    end

    context 'any part is set to zero' do
      let(:value) { { 3 => date.day, 2 => 0, 1 => date.year } }

      it { expect(coerced_value).to eq(value) }
    end

    context 'any part is set to nil' do
      let(:value) { { 3 => date.day, 2 => date.month, 1 => nil } }

      it { expect(coerced_value).to eq(value) }
    end

    context 'any part is missing from the hash' do
      let(:value) { { 3 => date.day, 2 => date.month } }

      it { expect(coerced_value).to eq(value) }
    end
  end

  describe '#value_from_multiparameter_assignment' do
    context 'override the superclass method' do
      it { expect(subject.value_from_multiparameter_assignment('foobar')).to eq('foobar') }
    end
  end
end
