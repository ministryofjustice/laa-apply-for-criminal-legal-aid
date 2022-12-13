require 'rails_helper'

RSpec.describe Steps::DWP::ConfirmDetailsForm do
  # NOTE: not using shared examples for form objects yet, to be added
  # once we have some more form objects and some patterns emerge

  describe '#choices' do
    it 'returns the possible choices' do
      expect(
        subject.choices
      ).to eq([YesNoAnswer::YES, YesNoAnswer::NO])
    end
  end

  describe '#save' do
    context 'when `confirm_details` is not provided' do
      it 'returns false' do
        expect(subject.save).to be(false)
      end

      it 'has a validation error on the field' do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:confirm_details, :inclusion)).to be(true)
      end
    end

    context 'when `confirm_details` is provided' do
      it 'returns true' do
        subject.choices.each do |choice|
          subject.confirm_details = choice
          expect(subject.save).to be(true)
        end
      end
    end
  end
end
