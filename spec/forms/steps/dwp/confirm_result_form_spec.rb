require 'rails_helper'

RSpec.describe Steps::DWP::ConfirmResultForm do
  # NOTE: not using shared examples for form objects yet, to be added
  # once we have some more form objects and some patterns emerge

  subject { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application:
    }
  end

  let(:crime_application) { instance_double(CrimeApplication, applicant:) }
  let(:applicant) { instance_double(Applicant) }

  context 'when dwp undetermined feature is enabled' do
    before do
      allow(FeatureFlags).to receive(:dwp_undetermined) {
        instance_double(FeatureFlags::EnabledFeature, enabled?: true)
      }
    end

    describe '#save' do
      context 'when form is saved' do
        it 'resets necessary applicant attributes' do
          expect(applicant).to receive(:update).with({
                                                       'benefit_type' => BenefitType::NONE,
                                                       'has_benefit_evidence' => nil,
                                                       'confirm_details' => nil
                                                     }).and_return(true)
          expect(subject.save).to be(true)
        end
      end
    end
  end

  context 'when dwp undetermined feature is disabled' do
    let(:arguments) do
      {
        crime_application:,
        confirm_dwp_result:,
      }
    end

    let(:applicant) { instance_double(Applicant, confirm_dwp_result:) }
    let(:confirm_dwp_result) { nil }

    describe '#choices' do
      it 'returns the possible choices' do
        expect(
          subject.choices
        ).to eq([YesNoAnswer::YES, YesNoAnswer::NO])
      end
    end

    describe '#save' do
      context 'when `confirm_dwp_result` is not provided' do
        it 'returns false' do
          expect(subject.save).to be(false)
        end

        it 'has a validation error on the field' do
          expect(subject).not_to be_valid
          expect(subject.errors.of_kind?(:confirm_dwp_result, :inclusion)).to be(true)
        end
      end

      context 'when `confirm_dwp_result` is provided' do
        context 'when `confirm_dwp_result` is `no`' do
          let(:confirm_dwp_result) { 'no' }

          it 'saves `confirm_dwp_result` value and returns true' do
            expect(applicant).to receive(:update)
              .with({ 'confirm_dwp_result' => YesNoAnswer::NO }).and_return(true)
            expect(subject.save).to be(true)
          end
        end

        context 'when `confirm_dwp_result` is `yes`' do
          let(:confirm_dwp_result) { 'yes' }

          it 'saves `confirm_dwp_result` value and returns true' do
            expect(applicant).to receive(:update)
              .with({ 'confirm_dwp_result' => YesNoAnswer::YES }).and_return(true)
            expect(applicant).to receive(:update).with({
                                                         'benefit_type' => BenefitType::NONE,
                                                         'has_benefit_evidence' => nil,
                                                         'confirm_details' => nil
                                                       }).and_return(true)
            expect(subject.save).to be(true)
          end
        end
      end
    end
  end
end
