require 'rails_helper'

RSpec.describe OutgoingsPaymentType do
  subject { described_class.new(value) }

  let(:value) { :foo }

  describe '.values' do
    it 'returns all possible values' do
      expect(described_class.values.map(&:to_s)).to eq(
        %w[
          rent
          mortgage
          board_and_lodging
          council_tax
          childcare
          maintenance
          legal_aid_contribution
        ]
      )
    end
  end
end
