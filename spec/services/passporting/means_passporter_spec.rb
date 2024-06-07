require 'rails_helper'

RSpec.describe Passporting::MeansPassporter do
  subject { described_class.new(crime_application) }

  let(:crime_application) {
    instance_double(
      CrimeApplication,
      case: case_record,
      applicant: applicant,
      resubmission?: resubmission?,
      is_means_tested: is_means_tested,
      partner_detail: nil
    )
  }

  let(:case_record) { instance_double(Case, case_type:, appeal_financial_circumstances_changed:) }
  let(:applicant) { instance_double(Applicant, under18?: under18, benefit_check_result: benefit_check_result) }

  let(:case_type) { 'either_way' }
  let(:appeal_financial_circumstances_changed) { nil }

  let(:resubmission?) { false }
  let(:under18) { nil }
  let(:benefit_check_result) { nil }
  let(:is_means_tested) { 'yes' }

  before do
    allow(crime_application).to receive(:update)
    allow(crime_application).to receive(:means_passport).and_return([])
  end

  describe '#call' do
    context 'for a resubmitted application' do
      let(:resubmission?) { true }

      it 'uses the existing values' do
        expect(crime_application).not_to receive(:update)
        expect(subject).to receive(:passported?)

        subject.call
      end
    end

    context 'means passporting on non-means tested' do
      let(:is_means_tested) { 'no' }

      before do
        allow(FeatureFlags).to receive(:non_means_tested) {
          instance_double(FeatureFlags::EnabledFeature, enabled?: true)
        }
      end

      it 'does not add an age passported type to the array' do
        expect(crime_application).to receive(:update).with(
          means_passport: [MeansPassportType::ON_NOT_MEANS_TESTED]
        )

        subject.call
      end
    end

    context 'means passporting on age' do
      context 'when applicant is over 18' do
        let(:under18) { false }

        it 'does not add an age passported type to the array' do
          expect(crime_application).to receive(:update).with(means_passport: [])

          subject.call
        end
      end

      context 'when applicant is under 18' do
        let(:under18) { true }

        it 'adds an age passported type to the array' do
          expect(
            crime_application
          ).to receive(:update).with(
            means_passport: [MeansPassportType::ON_AGE_UNDER18]
          )

          subject.call
        end
      end
    end

    context 'means passporting on benefit checker' do
      let(:under18) { false }

      context 'when DWP benefit check has been successful' do
        let(:benefit_check_result) { true }

        it 'adds a benefit passported type to the array' do
          expect(
            crime_application
          ).to receive(:update).with(
            means_passport: [MeansPassportType::ON_BENEFIT_CHECK]
          )

          subject.call
        end
      end

      context 'when DWP benefit check has failed' do
        let(:benefit_check_result) { false }

        it 'does not add a benefit passported type to the array' do
          expect(crime_application).to receive(:update).with(means_passport: [])

          subject.call
        end
      end

      context 'when DWP benefit check has not been performed' do
        let(:benefit_check_result) { nil }

        it 'does not add a benefit passported type to the array' do
          expect(crime_application).to receive(:update).with(means_passport: [])

          subject.call
        end
      end
    end
  end

  describe '#passported?' do
    it 'checks if any of the passporting kinds has triggered' do
      expect(subject).to receive(:age_passported?).and_return(false)
      expect(subject).to receive(:benefit_check_passported?).and_return(false)

      subject.passported?
    end
  end

  describe '#age_passported?' do
    context 'for a new application' do
      context 'for under 18' do
        let(:under18) { true }

        it { expect(subject.age_passported?).to be(true) }
      end

      context 'for over 18' do
        let(:under18) { false }

        it { expect(subject.age_passported?).to be(false) }
      end
    end

    context 'for a resubmitted application' do
      let(:resubmission?) { true }

      before do
        allow(crime_application).to receive(:means_passport).and_return(means_passport)
      end

      context 'passported on age' do
        let(:means_passport) { [MeansPassportType::ON_AGE_UNDER18.to_s] }

        it { expect(subject.age_passported?).to be(true) }
      end

      context 'not passported on age' do
        let(:means_passport) { [MeansPassportType::ON_BENEFIT_CHECK.to_s] }

        it { expect(subject.age_passported?).to be(false) }
      end
    end
  end

  describe '#benefit_check_passported?' do
    context 'for a new application' do
      context 'with benefit check passed' do
        let(:benefit_check_result) { true }

        it { expect(subject.benefit_check_passported?).to be(true) }
      end

      context 'with benefit check failed' do
        let(:benefit_check_result) { false }

        it { expect(subject.benefit_check_passported?).to be(false) }
      end
    end

    context 'for a resubmitted application' do
      let(:resubmission?) { true }

      before do
        allow(crime_application).to receive(:means_passport).and_return(means_passport)
      end

      context 'originally passported on benefit check' do
        let(:means_passport) { [MeansPassportType::ON_BENEFIT_CHECK.to_s] }

        it 'ignores the original means_passport' do
          expect(subject.benefit_check_passported?).to be(false)
        end
      end
    end
  end
end
