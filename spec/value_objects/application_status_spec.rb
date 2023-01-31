require 'rails_helper'

RSpec.describe ApplicationStatus do
  subject { described_class.new(value) }

  let(:value) { :foo }

  describe '.values' do
    it 'returns all possible values' do
      expect(described_class.values.map(&:to_s)).to eq(
        %w[in_progress submitted returned superseded]
      )
    end
  end

  describe '.enum_values' do
    it 'returns a map of values, used as the `status` enum definition' do
      expect(
        described_class.enum_values
      ).to eq({ in_progress: 'in_progress' })
    end
  end
end
