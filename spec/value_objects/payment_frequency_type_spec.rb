require 'rails_helper'

RSpec.describe PaymentFrequencyType do
  subject { described_class.new(value) }

  let(:value) { :foo }

  describe '.values' do
    it 'returns all possible values' do
      expect(described_class.values.map(&:to_s)).to eq(
        %w[
          weekly
          fortnightly
          four_weekly
          monthly
          yearly
        ]
      )
    end
  end
end
