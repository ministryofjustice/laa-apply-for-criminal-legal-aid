require 'rails_helper'

RSpec.describe ValueObject do
  before do
    stub_const('FooValue', Class.new(ValueObject))
    stub_const('BarValue', Class.new(ValueObject))
  end

  let(:value) { 'Hello!' }
  subject     { described_class.new(value) }

  let(:foo_one)      { FooValue.new('one') }
  let(:also_foo_one) { FooValue.new('one') }
  let(:foo_two)      { FooValue.new('two') }
  let(:bar_one)      { BarValue.new('one') }

  it 'is immutable' do
    expect(subject).to be_frozen
  end

  describe '#==' do
    it 'considers same class/same value equal' do
      expect(foo_one).to eq(also_foo_one)
    end

    it 'considers same class/different value not equal' do
      expect(foo_one).to_not eq(foo_two)
    end

    it 'considers different class/same value not equal' do
      expect(foo_one).to_not eq(bar_one)
    end

    it 'considers different class/different value not equal' do
      expect(foo_two).to_not eq(bar_one)
    end
  end

  describe '#hash' do
    it 'considers same class/same value equal' do
      expect(foo_one.hash).to eq(also_foo_one.hash)
    end

    it 'considers same class/different value not equal' do
      expect(foo_one.hash).to_not eq(foo_two.hash)
    end

    it 'considers different class/same value not equal' do
      expect(foo_one.hash).to_not eq(bar_one.hash)
    end

    it 'considers different class/different value not equal' do
      expect(foo_two.hash).to_not eq(bar_one.hash)
    end
  end

  describe '#to_s' do
    it 'returns the value as a string' do
      expect(foo_one.to_s).to eq('one')
    end
  end

  describe '#to_sym' do
    it 'returns the value (which is already a symbol)' do
      expect(foo_one.to_sym).to eq(:one)
    end
  end
end
