require 'rails_helper'

# forces size

RSpec.describe Type::Pence do
  subject(:pence) { described_class.new(**args) }

  let(:args) { {} }

  describe 'registry' do
    it 'is registered with ActiveModel type `:pence`' do
      expect(
        ActiveModel::Type.lookup(:pence).is_a?(described_class)
      ).to be(true)
    end

    it 'has an underlying type of `:pence`' do
      expect(subject.type).to eq(:pence)
    end
  end

  describe '#serialize' do
    subject(:serialized_value) { pence.serialize(value) }

    context 'when value is `nil`' do
      let(:value) { nil }

      it { is_expected.to be_nil }
    end

    context 'when value is a blank string' do
      let(:value) { '' }

      it { is_expected.to be_nil }
    end

    context 'when value is zero' do
      let(:value) { '0' }

      it { is_expected.to eq(0) }
    end

    context 'when value is non-numeric string' do
      let(:value) { 'wibble' }

      it { is_expected.to be_nil }
    end

    context 'when value is a float' do
      let(:value) { 1.23109923 }

      it { is_expected.to eq(123) }
    end

    context 'when value is -ve numeric string' do
      let(:value) { '-0.02' }

      it { is_expected.to eq(-2) }
    end

    context 'when value is a float string' do
      let(:value) { '321.019' }

      it 'is expected to truncate tenths of pennies' do
        expect(serialized_value).to eq(32_101)
      end

      it { is_expected.to be_a(Integer) }
    end

    context 'when value is a negative float string' do
      let(:value) { '-1.019' }

      it { is_expected.to eq(-101) }
    end

    context 'when value is an integer string' do
      let(:value) { '321' }

      it { is_expected.to eq(32_100) }
    end

    context 'when value is a numeric string with spaces' do
      let(:value) { ' 321 ' }

      it { is_expected.to eq(32_100) }
    end

    describe 'when value is an integer' do
      let(:value) { 123 }

      it 'assumes the value is already in pennies' do
        expect(subject).to eq(123)
      end
    end

    describe 'when value in pence exceeds 4bytes' do
      let(:value) { (2**31) * 0.01 }

      it 'is within range' do
        expect(subject).to eq(2_147_483_648)
      end
    end
  end

  describe '#deserialize' do
    subject(:deserialized_value) { pence.deserialize(value) }

    context 'when value is `nil`' do
      let(:value) { nil }

      it { is_expected.to be_nil }
    end

    context 'when value is zero' do
      let(:value) { 0 }

      it { is_expected.to eq '0.00' }
    end

    context 'when value positive Integer' do
      let(:value) { 123_120 }

      it { is_expected.to eq '1231.20' }
    end

    context 'when value is a negative Integer' do
      let(:value) { -1 }

      it { is_expected.to eq '-0.01' }
    end
  end

  describe '#cast' do
    subject(:cast_value) { pence.cast(value) }

    context 'when value is string' do
      let(:value) { '0.09' }

      it { is_expected.to eq '0.09' }
    end

    context 'when value is an integer' do
      let(:value) { 123 }

      it { is_expected.to eq '1.23' }
    end
  end
end
