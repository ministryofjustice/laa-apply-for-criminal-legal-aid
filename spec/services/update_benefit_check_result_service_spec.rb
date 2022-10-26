require 'rails_helper'

RSpec.describe UpdateBenefitCheckResultService do
  subject { described_class }

  let(:applicant) { double(Applicant) }

  before do
    allow(BenefitCheckService).to receive(:call).with(applicant).and_return(passporting_benefit)
    allow(applicant).to receive(:update).and_return(true)
  end

  describe '.call' do
    context 'with a `Yes` result' do
      let(:passporting_benefit) { true }

      it 'updates the applicant record with `true`' do
        subject.call(applicant) do
          expect(applicant).to receive(:update).with({ passporting_benefit: true })
        end
      end
    end

    context 'with a `No` result' do
      let(:passporting_benefit) { false }

      it 'updates the applicant record with `false`' do
        subject.call(applicant) do
          expect(applicant).to receive(:update).with(passporting_benefit: false)
        end
      end
    end
  end
end
