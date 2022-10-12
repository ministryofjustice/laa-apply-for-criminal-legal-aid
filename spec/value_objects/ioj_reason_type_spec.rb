require 'rails_helper'

RSpec.describe IojReasonType do
  subject { described_class.new(value) }

  let(:value) { :foo }

  describe '.values' do
    it 'returns all possible values' do
      expect(described_class.values.map(&:to_s)).to eq(%w[
                                                         loss_of_liberty
                                                         suspended_sentence
                                                         loss_of_livelyhood
                                                         reputation
                                                         question_of_law
                                                         understanding
                                                         witness_tracing
                                                         expert_examination
                                                         interest_of_another
                                                         other
                                                       ])
    end
  end
end
