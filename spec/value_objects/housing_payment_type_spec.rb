require 'rails_helper'

RSpec.describe HousingPaymentType do
  subject { described_class.new(value) }

  let(:value) { :foo }

  describe '.values' do
    it 'returns all possible values' do
      expect(described_class.values.map(&:to_s)).to eq(
        %w[
          rent
          mortgage
          board_lodgings
          none
        ]
      )
    end
  end
end
