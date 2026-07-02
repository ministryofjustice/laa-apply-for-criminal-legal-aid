require 'rails_helper'

RSpec.describe FrozenIncomeOrAssetsSubjectType do
  describe '.values' do
    it 'returns all possible values' do
      expect(described_class.values.map(&:to_s)).to eq(
        %w[
          applicant
          partner
          applicant_and_partner
        ]
      )
    end
  end
end
