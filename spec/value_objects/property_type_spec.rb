require 'rails_helper'

RSpec.describe PropertyType do
  subject { described_class.new(value) }

  describe '.values' do
    it 'returns all possible values' do
      expect(described_class.values.map(&:to_s)).to eq(%w[residential commercial land])
    end
  end
end
