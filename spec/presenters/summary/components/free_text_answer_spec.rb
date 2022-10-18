require 'rails_helper'

describe Summary::Components::FreeTextAnswer do
  subject { described_class.new(question, value) }

  let(:question) { 'Question?' }
  let(:value) { 'Answer!' }

  describe '#to_partial_path' do
    it 'returns the correct partial path' do
      expect(subject.to_partial_path).to eq('steps/submission/shared/free_text_answer')
    end
  end
end
