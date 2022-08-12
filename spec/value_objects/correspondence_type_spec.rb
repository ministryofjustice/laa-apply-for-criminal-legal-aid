require 'rails_helper'

RSpec.describe CorrespondenceType do
  subject { described_class.new(value) }

  let(:value) { :foo }

  describe '.values' do
    it 'returns all possible values' do
      expect(described_class.values.map(&:to_s)).to eq(
        %w(home_address providers_office_address other_address)
      )
    end
  end
end
