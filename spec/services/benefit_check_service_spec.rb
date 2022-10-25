require 'rails_helper'

RSpec.describe BenefitCheckService do
  subject { described_class.new(applicant) }

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
        result = described_class.call(applicant)
        expect(result[:benefit_checker_status]).to eq('Yes')
        expect(result[:confirmation_ref]).to match('mocked:')
      end

      context 'with matching data' do
        let(:date_of_birth) { '1955/01/11'.to_date }
        let(:nino) { 'ZZ123456A' }

        it 'returns true' do
          result = described_class.call(applicant)
          expect(result[:benefit_checker_status]).to eq('No')
          expect(result[:confirmation_ref]).to match('mocked:')
        end
      end
    end
  end
end
