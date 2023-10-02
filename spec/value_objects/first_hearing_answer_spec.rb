require 'rails_helper'

RSpec.describe FirstHearingAnswer do
  subject { described_class.new(value) }

  let(:value) { :foo }

  describe '.values' do
    it 'returns all possible values' do
      expect(described_class.values.map(&:to_s)).to eq(%w[yes no no_hearing_yet])
    end
  end
end
