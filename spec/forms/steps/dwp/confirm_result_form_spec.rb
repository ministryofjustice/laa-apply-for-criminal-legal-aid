require 'rails_helper'

RSpec.describe Steps::DWP::ConfirmResultForm do
  # NOTE: not using shared examples for form objects yet, to be added
  # once we have some more form objects and some patterns emerge

  subject { described_class.new(crime_application:) }

  let(:crime_application) { instance_double(CrimeApplication, applicant:) }
  let(:applicant) { instance_double(Applicant) }

  describe '#choices' do
    it 'returns the possible choices' do
      expect(
        subject.choices
      ).to eq([YesNoAnswer::YES, YesNoAnswer::NO])
    end
  end

  describe '#save' do
    context 'when `confirm_result` is not provided' do
      it 'returns false' do
        expect(subject.save).to be(false)
      end

      it 'has a validation error on the field' do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:confirm_result, :inclusion)).to be(true)
      end
    end

    context 'when `confirm_result` is provided' do
      context 'when `confirm_result` is `no`' do
        it 'returns true' do
          subject.confirm_result = 'no'
          expect(subject.save).to be(true)
        end
      end

      context 'when `confirm_result` is `yes`' do
        before do
          subject.confirm_result = 'yes'
        end

        it 'returns true and sets the benefit type to `none`' do
          expect(applicant).to receive(:update).with(benefit_type: BenefitType::NONE).and_return(true)
          expect(subject.save).to be(true)
        end
      end
    end
  end
end
