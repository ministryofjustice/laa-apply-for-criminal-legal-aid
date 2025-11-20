require 'rails_helper'

RSpec.describe DWP::UpdateBenefitCheckResultService do
  context 'when dwp undetermined feature is enabled' do
    before do
      allow(FeatureFlags).to receive(:dwp_undetermined) {
        instance_double(FeatureFlags::EnabledFeature, enabled?: true)
      }

      allow(DWP::BenefitCheckService).to receive(:benefit_check_result).with(applicant).and_return(benefit_check_result)
      allow(applicant).to receive(:update).and_return(true)
    end

    describe '.call' do
      let(:applicant) { double(Applicant) }

      context 'with a `Yes` result' do
        let(:benefit_check_result) { 'Yes' }

        it 'updates the applicant record' do
          expect(applicant).to receive(:update).with(dwp_response: 'Yes', benefit_check_result: true)
          described_class.call(applicant)
        end
      end

      context 'with a `No` result' do
        let(:benefit_check_result) { 'No' }

        it 'updates the applicant record' do
          expect(applicant).to receive(:update).with(dwp_response: 'No', benefit_check_result: false)
          described_class.call(applicant)
        end
      end

      context 'with an `Undetermined` result' do
        let(:benefit_check_result) { 'Undetermined' }

        it 'updates the applicant record' do
          expect(applicant).to receive(:update).with(dwp_response: 'Undetermined', benefit_check_result: false)
          described_class.call(applicant)
        end
      end
    end
  end

  context 'when dwp undetermined feature is disabled' do
    before do
      allow(DWP::BenefitCheckService).to receive(:passporting_benefit?).with(applicant).and_return(benefit_check_result)
      allow(applicant).to receive(:update).and_return(true)

      allow(FeatureFlags).to receive(:dwp_undetermined) {
        instance_double(FeatureFlags::EnabledFeature, enabled?: false)
      }
    end

    describe '.call' do
      let(:applicant) { double(Applicant) }

      context 'with a `Yes` result' do
        let(:benefit_check_result) { true }

        it 'updates the applicant record with `true`' do
          expect(applicant).to receive(:update).with(benefit_check_result: true)
          described_class.call(applicant)
        end
      end

      context 'with a `No` result' do
        let(:benefit_check_result) { false }

        it 'updates the applicant record with `false`' do
          expect(applicant).to receive(:update).with(benefit_check_result: false)
          described_class.call(applicant)
        end
      end
    end
  end
end
