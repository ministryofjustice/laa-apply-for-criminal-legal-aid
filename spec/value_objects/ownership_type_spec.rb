require 'rails_helper'

RSpec.describe OwnershipType do
  subject { described_class.new(value) }

  let(:value) { :foo }

  describe '.values' do
    it 'returns all possible values' do
      expect(described_class.values.map(&:to_s)).to eq(
        %w[
          applicant
          applicant_and_partner
          partner
        ]
      )
    end
  end

  describe '.exclusive' do
    it 'returns all possible values' do
      expect(described_class.exclusive.map(&:to_s)).to eq(
        %w[
          applicant
          partner
        ]
      )
    end
  end
end
