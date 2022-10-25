require 'rails_helper'

RSpec.describe MockBenefitCheckService do
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

  describe '.call' do
    it 'returns confirmation_ref' do
      expect(subject.call(applicant)[:confirmation_ref]).to eq("mocked:#{described_class}")
    end

    it "returns 'Yes' as in known data" do
      expect(subject.call(applicant)[:benefit_checker_status]).to eq('Yes')
    end

    context 'with incorrect date' do
      let(:date_of_birth) { '2012/01/10'.to_date }

      it 'returns no' do
        expect(subject.call(applicant)[:benefit_checker_status]).to eq('No')
      end

      it 'returns confirmation_ref' do
        expect(subject.call(applicant)[:confirmation_ref]).to eq("mocked:#{described_class}")
      end
    end

    context 'with unknown name' do
      let(:last_name) { 'Unknown' }

      it 'returns no' do
        expect(subject.call(applicant)[:benefit_checker_status]).to eq('No')
      end
    end
  end

  describe '.passporting_benefit?' do
    it 'returns true' do
      expect(subject.passporting_benefit?(applicant)).to be(true)
    end

    context 'with incorrect date' do
      let(:date_of_birth) { '2012/01/10'.to_date }

      it 'returns true' do
        expect(subject.passporting_benefit?(applicant)).to be(false)
      end
    end

    context 'with unknown name' do
      let(:last_name) { 'Unknown' }

      it 'returns false' do
        expect(subject.passporting_benefit?(applicant)).to be(false)
      end
    end
  end
end
