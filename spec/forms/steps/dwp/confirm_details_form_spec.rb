require 'rails_helper'

RSpec.describe Steps::DWP::ConfirmDetailsForm do
  # NOTE: not using shared examples for form objects yet, to be added
  # once we have some more form objects and some patterns emerge

  subject { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application:,
      confirm_details:,
    }
  end

  let(:crime_application) { instance_double(CrimeApplication, applicant:) }
  let(:applicant) { instance_double(Applicant, confirm_details:) }
  let(:confirm_details) { nil }

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
      context 'when `confirm_details` is `no`' do
        let(:confirm_details) { 'no' }

        it 'saves `confirm_details` value and returns true' do
          expect(applicant).to receive(:update).with({ 'confirm_details' => YesNoAnswer::NO }).and_return(true)
          expect(subject.save).to be(true)
        end
      end

      context 'when `confirm_details` is `yes`' do
        let(:confirm_details) { 'yes' }

        it 'saves `confirm_details` value and returns true' do
          expect(applicant).to receive(:update).with({ 'confirm_details' => YesNoAnswer::YES }).and_return(true)
          expect(subject.save).to be(true)
        end
      end
    end
  end
end
