require 'rails_helper'

RSpec.describe Offence, type: :model do
  describe '.find_by' do
    context 'can search by code' do
      subject { described_class.find_by(code: 'CJ88116') }

      it 'returns the offence found' do
        expect(subject).to be_a(described_class)
      end

      it 'has the offence attributes' do
        expect(subject.name).to eq('Assault by beating')
        expect(subject.offence_class).to eq('H')
        expect(subject.offence_type).to eq('CS Summary Non-Motoring')
        expect(subject.ioj_passport).to be(true)
      end
    end

    context 'can search by name' do
      subject { described_class.find_by(name: 'Drive whilst disqualified') }

      it 'returns the offence found' do
        expect(subject.code).to eq('RT88333')
        expect(subject.offence_class).to eq('H')
        expect(subject.offence_type).to eq('CM Summary - Motoring')
        expect(subject.ioj_passport).to be(false)
      end
    end

    context 'when no offence is found' do
      subject { described_class.find_by(code: 'XYZ123') }

      it { is_expected.to be_nil }
    end
  end

  describe '.find_by_name' do
    it 'is shorthand for `.find_by`' do
      expect(described_class).to receive(:find_by).with(name: 'Foobar')
      described_class.find_by(name: 'Foobar')
    end
  end

  describe '.all' do
    subject { described_class.all }

    it 'returns all offences' do
      expect(subject).to all(be_a(described_class))
      expect(subject.size).to eq(312)
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
        expect(offence_one).not_to eq(offence_three)
      end
    end

    describe '#hash' do
      it 'considers same type/same row equal' do
        expect(offence_one.hash).to eq(offence_two.hash)
      end

      it 'considers same type/different row not equal' do
        expect(offence_one.hash).not_to eq(offence_three.hash)
      end
    end
  end
end
