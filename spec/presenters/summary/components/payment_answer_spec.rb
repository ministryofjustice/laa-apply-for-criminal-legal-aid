require 'rails_helper'

describe Summary::Components::PaymentAnswer do
  subject { described_class.new(question, value) }

  let(:question) { 'How often is the client paid?' }
  let(:value) { '£16.89 every week' }

  describe '#to_partial_path' do
    it 'returns the correct partial path' do
      expect(subject.to_partial_path).to eq('steps/submission/shared/payment_answer')
    end
  end
end
