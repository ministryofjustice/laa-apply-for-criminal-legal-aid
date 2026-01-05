require 'rails_helper'

RSpec.describe DWP::UpdateBenefitCheckResultService do
  context 'when running the benefit checker' do
    before do
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
end
