require 'rails_helper'

RSpec.describe Slipstream::EligibilityChecker do
  subject(:checker) { described_class.new(crime_application) }

  let(:crime_application) do
    instance_double(CrimeApplication, case: kase, applicant: applicant, date_stamp: nil)
  end
  let(:applicant) { instance_double(Applicant, date_of_birth:) }
  let(:kase) { instance_double(Case, case_type:, charges:) }
  let(:case_type) { CaseType::SUMMARY_ONLY.to_s }
  let(:date_of_birth) { 18.years.ago.to_date }

  # 'Assault by beating' is slipstreamable, 'Make off without making payment' is not
  let(:slipstreamable_charge) { Charge.new(offence_name: 'Assault by beating') }
  let(:non_slipstreamable_charge) { Charge.new(offence_name: 'Make off without making payment') }
  let(:unlisted_charge) { Charge.new(offence_name: 'This is a test offence') }

  describe '#selection_reason' do
    context 'when the applicant is under 18' do
      let(:date_of_birth) { 17.years.ago.to_date }

      context 'with no charges' do
        let(:charges) { [] }

        it { is_expected.to have_attributes(selection_reason: :age, eligible?: true) }
      end

      context 'with a non-slipstreamable charge' do
        let(:charges) { [non_slipstreamable_charge] }

        it { is_expected.to have_attributes(selection_reason: :age, eligible?: true) }
      end

      context 'with multiple charges' do
        let(:charges) { [slipstreamable_charge, non_slipstreamable_charge] }

        it { is_expected.to have_attributes(selection_reason: :age, eligible?: true) }
      end

      context 'when also eligible by offence' do
        let(:charges) { [slipstreamable_charge] }

        it 'gives age priority' do
          expect(checker.selection_reason).to be(:age)
        end
      end

      context 'for an appeal application' do
        let(:case_type) { CaseType::APPEAL_TO_CROWN_COURT.to_s }
        let(:charges) { [non_slipstreamable_charge] }

        it { is_expected.not_to be_eligible }
      end

      context 'for an appeal application with an offence-eligible charge' do
        let(:case_type) { CaseType::APPEAL_TO_CROWN_COURT.to_s }
        let(:charges) { [slipstreamable_charge] }

        it 'remains eligible under the existing offence rule' do
          expect(checker.selection_reason).to be(:offence)
        end
      end
    end

    context 'when the applicant is 18 or older' do
      context 'with one slipstreamable charge' do
        let(:charges) { [slipstreamable_charge] }

        it { is_expected.to have_attributes(selection_reason: :offence, eligible?: true) }
      end

      context 'with one non-slipstreamable charge' do
        let(:charges) { [non_slipstreamable_charge] }

        it { is_expected.to have_attributes(selection_reason: nil, eligible?: false) }
      end

      context 'with an unlisted offence' do
        let(:charges) { [unlisted_charge] }

        it { is_expected.to have_attributes(selection_reason: nil, eligible?: false) }
      end

      context 'with multiple charges' do
        let(:charges) { [slipstreamable_charge, non_slipstreamable_charge] }

        it { is_expected.to have_attributes(selection_reason: nil, eligible?: false) }
      end

      context 'with multiple slipstreamable charges' do
        let(:charges) { [slipstreamable_charge, Charge.new(offence_name: 'Assault by beating')] }

        it { is_expected.to have_attributes(selection_reason: nil, eligible?: false) }
      end
    end

    context 'without a case' do
      let(:kase) { nil }
      let(:date_of_birth) { 17.years.ago.to_date }

      it { is_expected.to have_attributes(selection_reason: nil, eligible?: false) }
    end
  end
end
