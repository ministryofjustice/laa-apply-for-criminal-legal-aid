require 'rails_helper'

RSpec.describe Steps::Client::HasBenefitEvidenceForm do
  subject { described_class.new }

  describe '#choices' do
    it 'returns the possible choices' do
      expect(
        subject.choices
      ).to eq([YesNoAnswer::YES, YesNoAnswer::NO])
    end
  end

  describe '#save' do
    context 'when `has_benefit_evidence` is not provided' do
      it 'returns false' do
        expect(subject.save).to be(false)
      end

      it 'has a validation error on the field' do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:has_benefit_evidence, :inclusion)).to be(true)
      end
    end

    context 'when `confirm_result` is provided' do
      it 'returns true' do
        subject.choices.each do |choice|
          subject.has_benefit_evidence = choice
          expect(subject.save).to be(true)
        end
      end
    end
  end
end
