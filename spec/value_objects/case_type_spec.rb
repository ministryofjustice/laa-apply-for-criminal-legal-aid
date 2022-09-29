require 'rails_helper'

RSpec.describe CaseType do
  subject { described_class.new(value) }

  let(:value) { :foo }

  describe '.values' do
    it 'returns all possible values' do
      expect(described_class.values.map(&:to_s)).to eq(
        %w(
          summary_only 
          either_way 
          indictable 
          already_cc_trial 
          committal 
          cc_appeal 
          cc_appeal_fin_change
        )
      )
    end
  end

  describe '#date_stampable?' do
    context 'for date stampable case types' do
      it 'returns true' do
        date_stampable_types = [
          CaseType.new(:summary_only).date_stampable?,
          CaseType.new(:either_way).date_stampable?, 
          CaseType.new(:committal).date_stampable?, 
          CaseType.new(:cc_appeal).date_stampable?
        ]

        expect(date_stampable_types).to all(be_truthy)
      end
    end

    context 'for non date stampable case types' do
      it 'returns false' do
        date_stampable_types = [
          CaseType.new(:indictable).date_stampable?, 
          CaseType.new(:already_cc_trial).date_stampable?, 
          CaseType.new(:cc_appeal_fin_change).date_stampable?
        ]

        expect(date_stampable_types).to all(be_falsy)
      end
    end
  end
end
