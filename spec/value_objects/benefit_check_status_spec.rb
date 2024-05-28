require 'rails_helper'

RSpec.describe BenefitCheckStatus do
  subject { described_class.new(value) }

  let(:value) { :foo }

  describe '.values' do
    it 'returns all possible values' do
      expect(described_class.values.map(&:to_s)).to eq(
        %w[no_check_no_nino undetermined no_record_found no_check_required checker_unavailable confirmed]
      )
    end
  end
end
