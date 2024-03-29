require 'rails_helper'

RSpec.describe ValueObject do
  subject { described_class.new(value) }

  before do
    stub_const('FooValue', Class.new(described_class))
    stub_const('BarValue', Class.new(described_class))
  end

  let(:value) { 'Hello!' }
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
      expect(foo_one).not_to eq(foo_two)
    end

    it 'considers different class/same value not equal' do
      expect(foo_one).not_to eq(bar_one)
    end

    it 'considers different class/different value not equal' do
      expect(foo_two).not_to eq(bar_one)
    end
  end

  describe '#hash' do
    it 'considers same class/same value equal' do
      expect(foo_one.hash).to eq(also_foo_one.hash)
    end

    it 'considers same class/different value not equal' do
      expect(foo_one.hash).not_to eq(foo_two.hash)
    end

    it 'considers different class/same value not equal' do
      expect(foo_one.hash).not_to eq(bar_one.hash)
    end

    it 'considers different class/different value not equal' do
      expect(foo_two.hash).not_to eq(bar_one.hash)
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

  describe '.values' do
    it 'returns an empty array for the superclass' do
      expect(described_class.values).to eq([])
    end
  end

  describe 'inquiry methods' do
    let(:yes_answer) { YesNoAnswer.new(:yes) }
    let(:no_answer)  { YesNoAnswer.new(:no) }

    it 'has a constant with the inquiry methods' do
      expect(
        YesNoAnswer::INQUIRY_METHODS
      ).to match_array(%i[yes? no?])
    end

    it 'defines inquiry methods for each of the values' do
      expect(yes_answer.yes?).to be(true)
      expect(yes_answer.no?).to be(false)

      expect(no_answer.yes?).to be(false)
      expect(no_answer.no?).to be(true)
    end
  end
end
