require 'rails_helper'

RSpec.describe DWP::UpdateBenefitCheckResultService do
  before do
    allow(DWP::BenefitCheckService).to receive(:call).with(applicant).and_return(passporting_benefit)
    allow(applicant).to receive(:update).and_return(true)
  end

  describe '.call' do
    let(:applicant) { double(Applicant) }

    context 'with a `Yes` result' do
      let(:passporting_benefit) { true }

      it 'updates the applicant record with `true`' do
        expect(applicant).to receive(:update).with({ passporting_benefit: true })
        described_class.call(applicant)
      end
    end

    context 'with a `No` result' do
      let(:passporting_benefit) { false }

      it 'updates the applicant record with `false`' do
        expect(applicant).to receive(:update).with(passporting_benefit: false)
        described_class.call(applicant)
      end
    end
  end
end
