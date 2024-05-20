require 'rails_helper'

RSpec.describe Income, type: :model do
  subject(:income) { described_class.new }

  describe 'validations' do
    let(:answers_validator) { double('answers_validator') }

    before do
      allow(IncomeAssessment::AnswersValidator).to receive(:new).with(record: income)
                                                                .and_return(answers_validator)
    end

    describe 'valid?(:submission)' do
      it 'validates answers' do
        expect(answers_validator).to receive(:validate)

        income.valid?(:submission)
      end
    end
  end

  describe '#complete?' do
    context 'when income is complete' do
      it 'returns true' do
        expect(income).to receive(:valid?).with(:submission).and_return(true)
        expect(income.complete?).to be true
      end
    end

    context 'when income is incomplete' do
      it 'returns false' do
        expect(income).to receive(:valid?).with(:submission).and_return(false)
        expect(income.complete?).to be false
      end
    end
  end
end
