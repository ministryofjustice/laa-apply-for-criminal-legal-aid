require 'rails_helper'

RSpec.describe Evidence::Rules::BenefitsInKind do
  subject { described_class.new(crime_application) }

  let(:crime_application) do
    CrimeApplication.create!(income:)
  end

  let(:income) { Income.new }
  let(:include_partner?) { true }

  before do
    allow(MeansStatus).to receive_messages(include_partner?: include_partner?, full_means_required?: true)
  end

  it { expect(described_class.key).to eq :income_noncash_benefit_4 }
  it { expect(described_class.group).to eq :income }
  it { expect(described_class.archived).to be false }
  it { expect(described_class.active?).to be true }

  describe '.client' do
    subject { described_class.new(crime_application).client_predicate }

    context 'when client employed' do
      before do
        income.employment_status = ['employed']
      end

      context 'when applicant receives non cash benefit' do
        let(:income) { Income.new(applicant_other_work_benefit_received: 'yes') }

        it { is_expected.to be true }
      end

      context 'when applicant does not receive non cash benefit' do
        let(:income) { Income.new(applicant_other_work_benefit_received: 'no') }

        it { is_expected.to be false }
      end

      context 'question was not asked' do
        let(:income) { Income.new(applicant_other_work_benefit_received: nil) }

        it { is_expected.to be false }
      end
    end

    context 'income is not present' do
      let(:income) { nil }

      it { is_expected.to be false }
    end
  end

  describe '.partner' do
    subject { described_class.new(crime_application).partner_predicate }

    context 'when partner employed' do
      before do
        income.partner_employment_status = ['employed']
      end

      context 'when partner receives non cash benefit' do
        let(:income) { Income.new(partner_other_work_benefit_received: 'yes') }

        it { is_expected.to be true }
      end

      context 'when partner does not receive non cash benefit' do
        let(:income) { Income.new(partner_other_work_benefit_received: 'no') }

        it { is_expected.to be false }
      end

      context 'when question was not asked' do
        let(:income) { Income.new(partner_other_work_benefit_received: nil) }

        it { is_expected.to be false }
      end

      context 'when there is no partner' do
        let(:include_partner?) { false }

        it { is_expected.to be false }
      end
    end

    context 'income is not present' do
      let(:income) { nil }

      it { is_expected.to be false }
    end
  end

  describe '.other' do
    it { expect(subject.other_predicate).to be false }
  end

  describe '#to_h' do
    let(:income) do
      Income.new(
        applicant_other_work_benefit_received: 'yes',
        partner_other_work_benefit_received: 'yes',
        employment_status: ['employed'],
        partner_employment_status: ['employed']
      )
    end

    let(:expected_hash) do
      {
        id: 'BenefitsInKind',
        group: :income,
        ruleset: nil,
        key: :income_noncash_benefit_4,
        run: {
          client: {
            result: true,
            prompt: ["their P11D form for 'benefits in kind'"],
          },
          partner: {
            result: true,
            prompt: ["their P11D form for 'benefits in kind'"],
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
