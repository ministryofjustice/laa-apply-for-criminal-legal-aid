require 'rails_helper'

RSpec.describe UsualPropertyDetailsCapitalAnswer do
  subject { described_class.new(value) }

  let(:value) { :foo }

  describe '.values' do
    it 'returns all possible values' do
      expect(described_class.values.map(&:to_s)).to eq(%w[provide_details change_answer])
    end
  end
end
