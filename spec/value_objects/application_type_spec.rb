require 'rails_helper'

RSpec.describe ApplicationType do
  subject { described_class.new(value) }

  let(:value) { :foo }

  describe '.values' do
    it 'returns all possible values' do
      expect(described_class.values.map(&:to_s)).to eq(
        %w[initial post_submission_evidence change_in_financial_circumstances]
      )
    end
  end
end
