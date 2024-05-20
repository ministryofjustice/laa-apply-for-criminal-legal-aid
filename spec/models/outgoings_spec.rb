require 'rails_helper'

RSpec.describe Outgoings, type: :model do
  subject(:outgoings) { described_class.new }

  describe 'validations' do
    let(:answers_validator) { double('answers_validator') }

    before do
      allow(OutgoingsAssessment::AnswersValidator).to receive(:new).with(record: outgoings)
                                                                   .and_return(answers_validator)
    end

    describe 'valid?(:submission)' do
      it 'validates answers' do
        expect(answers_validator).to receive(:validate)

        outgoings.valid?(:submission)
      end
    end
  end

  describe '#complete?' do
    context 'when outgoings is complete' do
      it 'returns true' do
        expect(outgoings).to receive(:valid?).with(:submission).and_return(true)
        expect(outgoings.complete?).to be true
      end
    end

    context 'when outgoings is incomplete' do
      it 'returns false' do
        expect(outgoings).to receive(:valid?).with(:submission).and_return(false)
        expect(outgoings.complete?).to be false
      end
    end
  end
end
