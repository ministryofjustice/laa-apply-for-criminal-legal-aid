require 'rails_helper'

RSpec.describe DWP::UpdateBenefitCheckResultService do
  before do
    allow(DWP::BenefitCheckService).to receive(:passporting_benefit?).with(applicant).and_return(benefit_check_result)
    allow(applicant).to receive(:update).and_return(true)
  end

  describe '.call' do
    let(:applicant) { double(Applicant) }

    context 'with a `Yes` result' do
      let(:benefit_check_result) { true }

      it 'updates the applicant record with `true`' do
        expect(applicant).to receive(:update).with({ benefit_check_result: true })
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
