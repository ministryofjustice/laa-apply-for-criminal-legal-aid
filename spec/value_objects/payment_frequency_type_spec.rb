require 'rails_helper'

RSpec.describe PaymentFrequencyType do
  subject { described_class.new(value) }

  let(:value) { :foo }

  describe '.values' do
    it 'returns all possible values' do
      expect(described_class.values.map(&:to_s)).to eq(
        %w[
          week
          fortnight
          four_weeks
          month
          annual
        ]
      )
    end
  end

  describe '.to_phrase' do
    it 'returns the human name of the frequency' do
      expect(described_class::WEEKLY.to_phrase).to eq 'week'
      expect(described_class::FORTNIGHTLY.to_phrase).to eq '2 weeks'
      expect(described_class::FOUR_WEEKLY.to_phrase).to eq '4 weeks'
      expect(described_class::MONTHLY.to_phrase).to eq 'month'
      expect(described_class::ANNUALLY.to_phrase).to eq 'year'
    end
  end

  describe '#to_phrase' do
    it 'returns the human name of the frequency' do
      expect(described_class.to_phrase(:week)).to eq 'week'
      expect(described_class.to_phrase(:fortnight)).to eq '2 weeks'
      expect(described_class.to_phrase(:four_weeks)).to eq '4 weeks'
      expect(described_class.to_phrase(:month)).to eq 'month'
      expect(described_class.to_phrase(:annual)).to eq 'year'
    end
  end
end
