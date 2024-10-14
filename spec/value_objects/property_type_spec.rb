require 'rails_helper'

RSpec.describe PropertyType do
  subject { described_class.new(value) }

  describe '.values' do
    it 'returns all possible values' do
      expect(described_class.values.map(&:to_s)).to eq(%w[residential commercial land])
    end
  end

  describe '.to_phrase' do
    it 'returns the asset name' do
      expect(described_class::RESIDENTIAL.to_phrase).to eq 'residential property'
      expect(described_class::COMMERCIAL.to_phrase).to eq 'commercial property'
      expect(described_class::LAND.to_phrase).to eq 'land'
    end
  end

  describe '#to_phrase' do
    it 'returns the human name of the frequency' do
      expect(described_class.to_phrase(:residential)).to eq 'residential property'
      expect(described_class.to_phrase(:commercial)).to eq 'commercial property'
      expect(described_class.to_phrase(:land)).to eq 'land'
    end
  end
end
