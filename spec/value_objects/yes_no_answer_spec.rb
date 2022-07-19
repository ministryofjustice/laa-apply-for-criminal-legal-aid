require 'rails_helper'

RSpec.describe YesNoAnswer do
  subject { described_class.new(value) }

  let(:value) { :foo }

  describe '.values' do
    it 'returns all possible values' do
      expect(described_class.values.map(&:to_s)).to eq(%w(yes no))
    end
  end

  describe '#yes?' do
    context 'when value is `yes`' do
      let(:value) { :yes }
      it { expect(subject.yes?).to eq(true) }
    end

    context 'when value is not `yes`' do
      let(:value) { :no }
      it { expect(subject.yes?).to eq(false) }
    end
  end

  describe '#no?' do
    context 'when value is `no`' do
      let(:value) { :no }
      it { expect(subject.no?).to eq(true) }
    end

    context 'when value is not `no`' do
      let(:value) { :yes }
      it { expect(subject.no?).to eq(false) }
    end
  end
end
