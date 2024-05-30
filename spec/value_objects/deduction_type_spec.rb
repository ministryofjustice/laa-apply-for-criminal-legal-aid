require 'rails_helper'

RSpec.describe DeductionType do
  subject { described_class.new(value) }

  let(:value) { :foo }

  describe '.values' do
    it 'returns all possible values' do
      expect(described_class.values.map(&:to_s)).to eq(
        %w[
          income_tax
          national_insurance
          other
        ]
      )
    end
  end
end
