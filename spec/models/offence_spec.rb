require 'rails_helper'

RSpec.describe Offence, type: :model do
  describe '.find_by' do
    context 'can search by code' do
      subject { described_class.find_by(code: 'FA06001') }

      it 'returns the offence found' do
        expect(subject).to be_a(described_class)
      end

      it 'has the offence attributes' do
        expect(subject.code).to eq('FA06001')
        expect(subject.name).to eq('Fraud by false representation')
        expect(subject.offence_class).to eq('F/G/K')
        expect(subject.offence_type).to eq('CE Either Way')
      end
    end

    context 'can search by name' do
      subject { described_class.find_by(name: 'Fraud by false representation') }

      it 'returns the offence found' do
        expect(subject.code).to eq('FA06001')
      end
    end

    context 'when no offence is found' do
      subject { described_class.find_by(code: 'XYZ123') }
      it { is_expected.to be_nil }
    end
  end

  describe '.all' do
    subject { described_class.all }

    it 'returns all offences' do
      expect(subject).to all(be_a(described_class))
      expect(subject.size).to eq(233)
    end

    it 'keeps the same order as in the CSV file' do
      expect(subject.first.code).to eq('TH68010')
      expect(subject.last.code).to eq('TH68006A')
    end
  end

  describe 'equality methods' do
    let(:offence_one) { described_class.new(row: 'row_A') }
    let(:offence_two) { described_class.new(row: 'row_A') }
    let(:offence_three) { described_class.new(row: 'row_B') }

    describe '#==' do
      it 'considers same type/same row equal' do
        expect(offence_one).to eq(offence_two)
      end

      it 'considers same type/different row not equal' do
        expect(offence_one).to_not eq(offence_three)
      end
    end

    describe '#hash' do
      it 'considers same type/same row equal' do
        expect(offence_one.hash).to eq(offence_two.hash)
      end

      it 'considers same type/different row not equal' do
        expect(offence_one.hash).to_not eq(offence_three.hash)
      end
    end
  end
end
