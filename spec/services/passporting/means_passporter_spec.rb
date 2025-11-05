require 'rails_helper'

RSpec.describe Passporting::MeansPassporter do
  subject(:passporter) { described_class.new(crime_application) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      case: instance_double(Case, case_type:, appeal_financial_circumstances_changed:),
      applicant: instance_double(Applicant, date_of_birth:, benefit_check_result:, dwp_response:),
      resubmission?: resubmission?,
      is_means_tested: is_means_tested,
      date_stamp: date_stamp,
      partner_detail: nil,
      partner: nil,
      non_means_tested?: false
    )
  end

  let(:case_type) { 'either_way' }
  let(:appeal_financial_circumstances_changed) { nil }
  let(:resubmission?) { false }
  let(:under18) { nil }
  let(:date_stamp) { nil }
  let(:benefit_check_result) { nil }
  let(:dwp_response) { nil }
  let(:is_means_tested) { 'yes' }

  let(:date_of_birth) do
    return nil if under18.nil?

    under18 ? 18.years.ago.next_day : 18.years.ago
  end

  describe '#means_passport' do
    subject(:means_passport) { passporter.means_passport }

    context 'when date of birth is not known' do
      let(:under18) { nil }

      it { is_expected.to eq([]) }
    end

    context 'when applicant is over 18' do
      let(:under18) { false }

      it { is_expected.to eq([]) }
    end

    context 'when applicant is over 18 but was under 18 at date_stamp' do
      let(:under18) { false }
      let(:date_stamp) { 1.day.ago }

      it { is_expected.to eq([MeansPassportType::ON_AGE_UNDER18]) }
    end

    context 'when applicant is over 18 and was over 18 at date_stamp' do
      let(:date_of_birth) { 18.years.ago - 1.week }
      let(:date_stamp) { 6.days.ago }

      it { is_expected.to eq [] }
    end

    context 'when applicant is under 18' do
      let(:under18) { true }

      it { is_expected.to eq([MeansPassportType::ON_AGE_UNDER18]) }
    end

    context 'when DWP benefit check has been successful' do
      let(:under18) { false }

      context 'when dwp_response is `Yes`' do
        let(:dwp_response) { 'Yes' }

        before do
          allow(FeatureFlags).to receive(:dwp_undetermined) {
            instance_double(FeatureFlags::EnabledFeature, enabled?: true)
          }
        end

        it { is_expected.to eq([MeansPassportType::ON_BENEFIT_CHECK]) }
      end

      context 'when benefit_check_result is `true`' do
        let(:benefit_check_result) { true }

        it { is_expected.to eq([MeansPassportType::ON_BENEFIT_CHECK]) }
      end
    end

    context 'when DWP benefit check has failed' do
      let(:under18) { false }

      context 'when dwp undetermined feature is enabled' do
        before do
          allow(FeatureFlags).to receive(:dwp_undetermined) {
            instance_double(FeatureFlags::EnabledFeature, enabled?: true)
          }
        end

        context 'when dwp_response is `No`' do
          let(:dwp_response) { 'No' }

          it { is_expected.to eq([]) }
        end

        context 'when dwp_response is `Undetermined`' do
          let(:dwp_response) { 'Undetermined' }

          it { is_expected.to eq([]) }
        end
      end

      context 'when benefit_check_result is not performed' do
        let(:benefit_check_result) { false }

        it { is_expected.to eq([]) }
      end
    end

    context 'when means passporting on non-means tested' do
      let(:is_means_tested) { 'no' }

      it { is_expected.to eq([MeansPassportType::ON_NOT_MEANS_TESTED]) }
    end
  end

  describe 'passported?' do
    subject(:passported?) { passporter.passported? }

    context 'when means passported' do
      let(:under18) { true }

      it { is_expected.to be(true) }
    end

    context 'when not means passported' do
      let(:under18) { false }

      it { is_expected.to be(false) }
    end
  end

  describe '#age_passported?' do
    subject(:age_passported?) { passporter.age_passported? }

    context 'when applicant is over 18' do
      let(:under18) { true }

      it { is_expected.to be(true) }
    end

    context 'when benefit check passported' do
      let(:under18) { false }

      context 'when dwp_response is `Yes`' do
        let(:dwp_response) { 'Yes' }

        before do
          allow(FeatureFlags).to receive(:dwp_undetermined) {
            instance_double(FeatureFlags::EnabledFeature, enabled?: true)
          }
        end

        it { is_expected.to be(false) }
      end

      context 'when benefit_check_result is `true`' do
        let(:benefit_check_result) { true }

        it { is_expected.to be(false) }
      end
    end
  end
end
