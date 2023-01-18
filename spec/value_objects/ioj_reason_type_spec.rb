require 'rails_helper'

RSpec.describe IojReasonType do
  subject { described_class.new(value) }

  let(:value) { :foo }

  describe '.values' do
    it 'returns all possible values' do
      expect(described_class.values.map(&:to_s)).to eq(%w[
                                                         loss_of_liberty
                                                         suspended_sentence
                                                         loss_of_livelihood
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

  describe '.justification_attrs' do
    it 'returns all justification attribute names' do
      expect(
        described_class.justification_attrs
      ).to match_array(
        %i[
          loss_of_liberty_justification
          suspended_sentence_justification
          loss_of_livelihood_justification
          reputation_justification
          question_of_law_justification
          understanding_justification
          witness_tracing_justification
          expert_examination_justification
          interest_of_another_justification
          other_justification
        ]
      )
    end
  end
end
