require 'rails_helper'

RSpec.describe UpdateBenefitCheckResultService do
  subject { described_class }

  let(:last_name) { 'Smith' }
  let(:date_of_birth) { '1999/01/11'.to_date }
  let(:nino) { 'NC123459A' }

  let(:applicant) do
    double(
      Applicant,
      last_name:,
      date_of_birth:,
      nino:
    )
  end

  before do
    allow(BenefitCheckService).to receive(:call).with(applicant).and_return({ benefit_checker_status: })
    allow(applicant).to receive(:update).and_return(true)
  end

  describe '.call' do
    context 'with a `Yes` result' do
      let(:benefit_checker_status) { 'Yes' }

      it 'updates the applicant record with `true`' do
        subject.call(applicant) do
          expect(applicant).to receive(:update).with({ passporting_benefit: true })
        end
      end
    end

    context 'with a `No` result' do
      let(:benefit_checker_status) { 'No' }

      it 'updates the applicant record with `false`' do
        subject.call(applicant) do
          expect(applicant).to receive(:update).with(passporting_benefit: false)
        end
      end
    end
  end
end
