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
        expect(subject.slipstreamable).to be(true)
      end
    end

    context 'can search by name' do
      subject { described_class.find_by(name: 'Drive whilst disqualified') }

      it 'returns the offence found' do
        expect(subject.code).to eq('RT88333')
        expect(subject.offence_class).to eq('H')
        expect(subject.offence_type).to eq('CM Summary - Motoring')
        expect(subject.slipstreamable).to be(false)
      end
    end

    context 'when no offence is found' do
      subject { described_class.find_by(code: 'XYZ123') }

      it { is_expected.to be_nil }
    end
  end

  # This is a custom CSV lookup with legacy aliases, not an ActiveRecord dynamic finder.
  # rubocop:disable-next Rails/DynamicFindBy
  describe '.find_by_name' do
    bands = [
      ['£30,000 or less', 'F'],
      ['Over £30,000 up to £100,000', 'G'],
      ['Over £100,000', 'K'],
    ]

    it 'is shorthand for `.find_by`' do
      expect(described_class).to receive(:find_by).with(name: 'Foobar')
      described_class.find_by_name('Foobar')
    end

    [
      ['TH68072', 'Handling stolen goods - Theft Act 1968', 'Handle stolen goods, selling', true],
      ['TH68073', 'Handle stolen goods', 'Handling stolen goods, buying - Theft Act 1968', false],
    ].each do |code, old_name, new_name, slipstreamable|
      bands.each do |band, offence_class|
        context "for #{code} (#{band})" do
          let(:name) { "#{new_name} (#{band})" }
          let(:legacy_name) { "#{old_name} (#{band})" }

          it 'resolves the clarified name with the original classification and eligibility' do
            expect(described_class.find_by_name(name)).to have_attributes(
              name: name, code: code, offence_class: offence_class,
              offence_type: 'CE Either Way', slipstreamable: slipstreamable
            )
          end

          it 'resolves the historical name to the same offence without adding a selectable duplicate' do
            expect(described_class.find_by_name(legacy_name)).to eq(described_class.find_by_name(name))
            expect(described_class.all.map(&:name)).to include(name)
            expect(described_class.all.map(&:name)).not_to include(legacy_name)
          end
        end
      end
    end

    it 'does not resolve an unrecognised historical value band' do
      expect(described_class.find_by_name('Handle stolen goods (unknown value)')).to be_nil
    end

    it 'allows a missing name' do
      expect(described_class.find_by_name(nil)).to be_nil
    end
  end

  describe '.all' do
    subject { described_class.all }

    it 'returns all offences' do
      expect(subject).to all(be_a(described_class))
      expect(subject.size).to eq(313)
    end

    it 'keeps the same order as in the CSV file' do
      expect(subject.first.code).to eq('TH68010')
      expect(subject.last.code).to eq('SC15005')
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
