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
end
