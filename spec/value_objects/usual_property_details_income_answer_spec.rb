require 'rails_helper'

RSpec.describe UsualPropertyDetailsIncomeAnswer do
  subject { described_class.new(value) }

  let(:value) { :foo }

  describe '.values' do
    it 'returns all possible values' do
      expect(described_class.values.map(&:to_s)).to eq(%w[change_own_home_land_property change_residence_type])
    end
  end
end
