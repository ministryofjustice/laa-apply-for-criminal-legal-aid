require 'rails_helper'

RSpec.describe PartnerDetail, type: :model do
  subject(:partner_detail) { described_class.new }

  describe 'validations' do
    let(:answers_validator) { double('answers_validator') }

    before do
      allow(PartnerDetails::AnswersValidator).to(
        receive(:new).with(record: partner_detail).and_return(answers_validator)
      )
    end

    describe 'valid?(:submission)' do
      it 'validates answers' do
        expect(answers_validator).to receive(:validate)

        partner_detail.valid?(:submission)
      end
    end
  end

  describe '#complete?' do
    context 'when partner_detail is complete' do
      it 'returns true' do
        expect(partner_detail).to receive(:valid?).with(:submission).and_return(true)
        expect(partner_detail.complete?).to be true
      end
    end

    context 'when partner_detail is incomplete' do
      it 'returns false' do
        expect(partner_detail).to receive(:valid?).with(:submission).and_return(false)
        expect(partner_detail.complete?).to be false
      end
    end
  end
end
