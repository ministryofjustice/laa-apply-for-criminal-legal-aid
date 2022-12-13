require 'rails_helper'

RSpec.describe DWP::BenefitCheckService do
  subject { described_class.call(applicant) }

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

  describe '.call' do
    describe 'behaviour with mock' do
      before { stub_const('BenefitCheckService::USE_MOCK', true) }

      it 'returns the right parameters' do
        expect(subject).to be(true)
      end

      context 'with matching data' do
        let(:date_of_birth) { '1955/01/11'.to_date }
        let(:nino) { 'ZZ123456A' }

        it 'returns true' do
          expect(subject).to be(false)
        end
      end
    end
  end
end
