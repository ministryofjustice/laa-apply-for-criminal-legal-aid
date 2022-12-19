require 'rails_helper'

RSpec.describe Steps::Provider::ConfirmOfficeForm do
  subject { described_class.new(arguments) }

  let(:arguments) do
    { is_current_office: }
  end

  let(:is_current_office) { nil }

  describe '#choices' do
    it 'returns the possible choices' do
      expect(
        subject.choices
      ).to eq([YesNoAnswer::YES, YesNoAnswer::NO])
    end
  end

  describe '#save' do
    context 'when `is_current_office` is not provided' do
      it 'returns false' do
        expect(subject.save).to be(false)
      end

      it 'has a validation error on the field' do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:is_current_office, :inclusion)).to be(true)
      end
    end

    context 'when `is_current_office` is not valid' do
      let(:is_current_office) { 'maybe' }

      it 'returns false' do
        expect(subject.save).to be(false)
      end

      it 'has a validation error on the field' do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:is_current_office, :inclusion)).to be(true)
      end
    end

    context 'when form is valid' do
      let(:is_current_office) { 'yes' }

      it 'returns true' do
        expect(subject.save).to be(true)
      end
    end
  end
end
