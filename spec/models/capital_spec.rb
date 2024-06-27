require 'rails_helper'

RSpec.describe Capital, type: :model do
  subject(:capital) { described_class.new }

  describe 'validations' do
    let(:answers_validator) { double('answers_validator') }
    let(:confirmation_validator) { double('confirmation_validator') }

    before do
      allow(CapitalAssessment::AnswersValidator).to receive(:new).with(record: capital)
                                                                 .and_return(answers_validator)
      allow(CapitalAssessment::ConfirmationValidator).to receive(:new).with(capital)
                                                                      .and_return(confirmation_validator)
    end

    describe 'valid?(:submission)' do
      it 'validates both answers and confirmation' do
        expect(answers_validator).to receive(:validate)
        expect(confirmation_validator).to receive(:validate)

        capital.valid?(:submission)
      end
    end

    describe 'valid?(:check_answers)' do
      it 'validates answers only' do
        expect(answers_validator).to receive(:validate)
        expect(confirmation_validator).not_to receive(:validate)

        capital.valid?(:check_answers)
      end
    end
  end

  describe '#complete?' do
    context 'when capital is complete' do
      it 'returns true' do
        expect(capital).to receive(:valid?).with(:submission).and_return(true)
        expect(capital.complete?).to be true
      end
    end

    context 'when capital is incomplete' do
      it 'returns false' do
        expect(capital).to receive(:valid?).with(:submission).and_return(false)
        expect(capital.complete?).to be false
      end
    end
  end

  it_behaves_like 'it has a means ownership scope'
end
