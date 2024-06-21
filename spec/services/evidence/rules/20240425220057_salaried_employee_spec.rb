require 'rails_helper'

RSpec.describe Evidence::Rules::SalariedEmployee do
  subject { described_class.new(crime_application) }

  let(:crime_application) do
    CrimeApplication.create!(
      income:,
      income_payments:,
    )
  end

  let(:income) { Income.new }
  let(:income_payments) { [] }
  let(:include_partner?) { true }

  before do
    allow(MeansStatus).to receive(:include_partner?).and_return(include_partner?)
  end

  it { expect(described_class.key).to eq :income_employed_0a }
  it { expect(described_class.group).to eq :income }
  it { expect(described_class.archived).to be false }
  it { expect(described_class.active?).to be true }

  describe '.client' do
    subject { described_class.new(crime_application).client_predicate }

    context 'when employed' do
      let(:income) { Income.new(employment_status: [EmploymentStatus::EMPLOYED]) }

      it { is_expected.to be true }
    end

    context 'when not employed' do
      let(:income) { Income.new(employment_status: [EmploymentStatus::NOT_WORKING]) }

      it { is_expected.to be false }
    end

    context 'when there is no employment status' do
      let(:income) { Income.new(employment_status: nil) }

      it { is_expected.to be false }
    end

    context 'when there is no income' do
      let(:income) { nil }

      it { is_expected.to be false }
    end
  end

  describe '.partner' do
    subject { described_class.new(crime_application).partner_predicate }

    context 'when employed' do
      let(:income) { Income.new(partner_employment_status: [EmploymentStatus::EMPLOYED]) }

      it { is_expected.to be true }
    end

    context 'when not employed' do
      let(:income) { Income.new(partner_employment_status: [EmploymentStatus::NOT_WORKING]) }

      it { is_expected.to be false }
    end

    context 'when there is no employment status' do
      let(:income) { Income.new(partner_employment_status: nil) }

      it { is_expected.to be false }
    end

    context 'when there is no income' do
      let(:income) { nil }

      it { is_expected.to be false }
    end
  end

  describe '.other' do
    it { expect(subject.other_predicate).to be false }
  end

  describe '#to_h' do
    let(:income) do
      Income.new(employment_status: [EmploymentStatus::EMPLOYED],
                 partner_employment_status: [EmploymentStatus::EMPLOYED])
    end

    let(:expected_hash) do
      {
        id: 'SalariedEmployee',
        group: :income,
        ruleset: nil,
        key: :income_employed_0a,
        run: {
          client: {
            result: true,
            prompt: ["wage slips, salary advice, or a letter from their employer if they're paid by cash"],
          },
          partner: {
            result: true,
            prompt: ["wage slips, salary advice, or a letter from their employer if they're paid by cash"],
          },
          other: {
            result: false,
            prompt: [],
          },
        }
      }
    end

    it { expect(subject.to_h).to eq expected_hash }
  end
end
