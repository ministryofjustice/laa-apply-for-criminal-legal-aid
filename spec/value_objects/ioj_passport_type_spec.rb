require 'rails_helper'

RSpec.describe IojPassportType do
  subject { described_class.new(value) }

  let(:value) { :foo }

  describe '.values' do
    it 'returns all possible values' do
      expect(described_class.values.map(&:to_s)).to eq(
        %w[
          on_age_under18
          on_offence
        ]
      )
    end
  end
end
