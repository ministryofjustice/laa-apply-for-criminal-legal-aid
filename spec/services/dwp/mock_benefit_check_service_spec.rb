require 'rails_helper'

RSpec.describe DWP::MockBenefitCheckService do
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
    subject { described_class.call(applicant) }

    it 'returns confirmation_ref' do
      expect(subject[:confirmation_ref]).to eq("mocked:#{described_class}")
    end

    it "returns 'Yes' as in known data" do
      expect(subject[:benefit_checker_status]).to eq('Yes')
    end

    context 'when status is No' do
      let(:last_name) { 'Brown' }
      let(:date_of_birth) { '1986/07/01'.to_date }
      let(:nino) { 'PA435162A' }

      it "returns 'No' with known data" do
        expect(subject[:benefit_checker_status]).to eq('No')
      end
    end

    context 'with incorrect date' do
      let(:date_of_birth) { '2012/01/10'.to_date }

      it 'returns undetermined' do
        expect(subject[:benefit_checker_status]).to eq('Undetermined')
      end

      it 'returns confirmation_ref' do
        expect(subject[:confirmation_ref]).to eq("mocked:#{described_class}")
      end
    end

    context 'with unknown name' do
      let(:last_name) { 'Unknown' }

      it 'returns undetermined' do
        expect(subject[:benefit_checker_status]).to eq('Undetermined')
      end
    end
  end
end
