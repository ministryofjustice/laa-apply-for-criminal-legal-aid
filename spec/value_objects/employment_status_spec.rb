require 'rails_helper'

RSpec.describe EmploymentStatus do
  subject { described_class.new(value) }

  let(:value) { :foo }

  describe '.values' do
    it 'returns all possible values' do
      expect(described_class.values.map(&:to_s)).to eq(
        %w[
          employed
          self_employed
          not_working
        ]
      )
    end
  end
end
