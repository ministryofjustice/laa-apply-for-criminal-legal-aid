require 'rails_helper'

RSpec.describe Type::ValueObject do
  # NOTE: we will test this Type with `YesNoAnswer` as the source,
  # but any other value-object behaves the same, no need to test them all.
  subject { described_class.new(source: YesNoAnswer) }

  let(:coerced_value) { subject.cast(value) }

  describe 'registry' do
    it 'is registered with type `:value_object`' do
      expect(
        ActiveModel::Type.lookup(:value_object).is_a?(described_class)
      ).to be(true)
    end

    it 'has an underlying type of `:value_object`' do
      expect(subject.type).to eq(:value_object)
    end
  end

  describe 'when value is `nil`' do
    let(:value) { nil }

    it { expect(coerced_value).to be_nil }
  end

  describe 'when value is a symbol' do
    let(:value) { :yes }

    it { expect(coerced_value).to eq(YesNoAnswer::YES) }
  end

  describe 'when value is a string' do
    let(:value) { 'yes' }

    it { expect(coerced_value).to eq(YesNoAnswer::YES) }
  end

  describe 'when value is already a value-object' do
    let(:value) { YesNoAnswer::YES }

    it { expect(coerced_value).to eq(YesNoAnswer::YES) }
  end

  describe '#serialize' do
    let(:value) { YesNoAnswer::NO }

    it 'casts a value from the ruby type to a type that the database knows how to understand' do
      expect(
        subject.serialize(value)
      ).to eq('no')
    end
  end

  describe 'identity methods' do
    let(:type_one) { described_class.new(source: String) }
    let(:type_two) { described_class.new(source: String) }
    let(:type_three) { described_class.new(source: DateTime) }

    describe '#==' do
      it 'considers same type/same source equal' do
        expect(type_one).to eq(type_two)
      end

      it 'considers same type/different source not equal' do
        expect(type_one).not_to eq(type_three)
      end
    end

    describe '#hash' do
      it 'considers same type/same source equal' do
        expect(type_one.hash).to eq(type_two.hash)
      end

      it 'considers same type/different source not equal' do
        expect(type_one.hash).not_to eq(type_three.hash)
      end
    end
  end
end
