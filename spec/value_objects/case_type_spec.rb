require 'rails_helper'

RSpec.describe CaseType do
  subject { described_class.new(value) }

  let(:value) { :foo }

  describe '.values' do
    it 'returns all possible values' do
      expect(described_class.values.map(&:to_s)).to eq(
        %w[
          summary_only
          either_way
          indictable
          already_in_crown_court
          committal
          appeal_to_crown_court
          appeal_to_crown_court_with_changes
        ]
      )
    end
  end

  describe 'DATE_STAMPABLE' do
    it 'returns date stampable values' do
      expect(described_class::DATE_STAMPABLE.map(&:to_s)).to eq(
        %w[
          summary_only
          either_way
          committal
          appeal_to_crown_court
          appeal_to_crown_court_with_changes
        ]
      )
    end
  end

  describe '#date_stampable?' do
    context 'for date stampable case types' do
      it 'returns true' do
        date_stampable_types = described_class::DATE_STAMPABLE

        expect(
          date_stampable_types.map(&:date_stampable?)
        ).to all(be_truthy)
      end
    end

    context 'for non date stampable case types' do
      it 'returns false' do
        non_date_stampable_types = described_class.values - described_class::DATE_STAMPABLE

        expect(
          non_date_stampable_types.map(&:date_stampable?)
        ).to all(be_falsy)
      end
    end
  end
end
