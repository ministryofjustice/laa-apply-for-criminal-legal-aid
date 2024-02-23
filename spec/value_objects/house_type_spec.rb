require 'rails_helper'

RSpec.describe HouseType do
  subject { described_class.new(value) }

  describe '.values' do
    it 'returns all possible values' do
      expect(described_class.values.map(&:to_s)).to eq(%w[bungalow detached flat_or_maisonette semidetached terraced])
    end
  end
end
