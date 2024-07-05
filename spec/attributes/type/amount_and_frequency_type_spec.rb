require 'rails_helper'

RSpec.describe Type::AmountAndFrequencyType do
  subject(:type) { described_class.new }

  describe '#type' do
    it 'returns :amount_and_frequency' do
      expect(type.type).to eq(:amount_and_frequency)
    end
  end

  describe '#cast' do
    subject(:result) { type.cast(value) }

    context 'when value is a String' do
      let(:value) { '{"amount": 100, "frequency": "month"}' }

      it 'loads from json' do
        expect(result).to be_an_instance_of(AmountAndFrequency)
        expect(result.amount).to eq(100)
        expect(result.frequency).to eq(PaymentFrequencyType::MONTHLY)
      end
    end

    context 'when value is a Hash' do
      let(:value) { { amount: 100, frequency: 'month' } }

      it 'casts to AmountAndFrequency' do
        expect(result).to be_an_instance_of(AmountAndFrequency)
        expect(result.amount).to eq(100)
        expect(result.frequency).to eq(PaymentFrequencyType::MONTHLY)
      end
    end

    context 'when value is an AmountAndFrequency' do
      let(:value) { AmountAndFrequency.new(amount: 100, frequency: PaymentFrequencyType::MONTHLY) }

      it 'returns the value as is' do
        expect(result).to be(value)
      end
    end

    context 'when value is a Dry::Struct' do
      let(:value) { LaaCrimeSchemas::Structs::Amount.new(amount: 10_001, frequency: 'week') }

      it 'casts to AmountAndFrequency' do
        expect(result).to be_an_instance_of(AmountAndFrequency)
        expect(result.amount).to eq(Money.new(10_001))
        expect(result.frequency).to eq(PaymentFrequencyType::WEEKLY)
      end
    end
  end

  describe '#serialize' do
    subject(:result) { type.serialize(value) }

    context 'when value is a Hash' do
      let(:value) { { amount: 100, frequency: 'monthly' } }

      it 'serializes to JSON' do
        expect(result).to eq(value.to_json)
      end
    end

    context 'when value is an AmountAndFrequency' do
      let(:value) { AmountAndFrequency.new(amount: 1200, frequency: 'four_weeks') }

      it 'serializes to JSON' do
        expect(result).to eq(value.to_json)
      end
    end

    context 'when value is something else' do
      let(:value) { 'some thing else' }

      it 'calls super' do
        type.serialize(value)
      end
    end
  end

  describe '#deserialize' do
    subject(:result) { type.deserialize(value) }

    let(:value) { '{"amount": 10001, "frequency": "fortnight"}' }

    it 'loads from json' do
      expect(result).to be_an_instance_of(AmountAndFrequency)
      expect(result.amount).to eq(10_001)
      expect(result.frequency).to eq(PaymentFrequencyType::FORTNIGHTLY)
    end
  end
end
