require 'rails_helper'

RSpec.describe ApplicationStatus do
  subject { described_class.new(value) }

  let(:value) { :foo }

  describe '.values' do
    it 'returns all possible values' do
      expect(described_class.values.map(&:to_s)).to eq(
        %w(initialised in_progress submitted)
      )
    end
  end

  describe '.enum_values' do
    it 'returns a map of values, used as an enum definition' do
      expect(
        described_class.enum_values
      ).to eq({ initialised: 'initialised', in_progress: 'in_progress', submitted: 'submitted' })
    end
  end

  describe '.viewable_statuses' do
    it 'returns a map of values, used as an enum definition' do
      expect(
        described_class.viewable_statuses
      ).to eq(['in_progress', 'submitted'])
    end
  end
end
