require 'rails_helper'

RSpec.describe ManageWithoutIncomeType do
  subject { described_class.new(value) }

  let(:value) { :foo }

  describe '.values' do
    it 'returns all possible values' do
      expect(described_class.values.map(&:to_s)).to eq(%w[
                                                         friends_sofa
                                                         family
                                                         homeless
                                                         custody
                                                         other
                                                       ])
    end
  end
end
