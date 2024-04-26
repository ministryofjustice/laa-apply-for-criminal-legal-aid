require 'rails_helper'

RSpec.describe Evidence::Rules::CashInvestments do
  subject { described_class.new(crime_application) }

  let(:crime_application) do
    CrimeApplication.create!(
      savings:
    )
  end

  let(:savings) { [] }

  it { expect(described_class.key).to eq :capital_cash_investments_20 }
  it { expect(described_class.group).to eq :capital }
  it { expect(described_class.archived).to be false }
  it { expect(described_class.active?).to be true }

  describe '.client' do
    subject { described_class.new(crime_application).client_predicate }

    context 'with other cash investments' do
      let(:savings) { [Saving.new(saving_type: 'other')] }

      it { is_expected.to be true }
    end

    context 'without other cash investments' do
      it { is_expected.to be false }
    end
  end

  describe '.partner' do
    it { expect(subject.partner_predicate).to be false }
  end

  describe '.other' do
    it { expect(subject.other_predicate).to be false }
  end

  describe '#to_h' do
    let(:savings) { [Saving.new(saving_type: 'other')] }

    let(:expected_hash) do
      {
        id: 'CashInvestments',
        group: :capital,
        ruleset: nil,
        key: :capital_cash_investments_20,
        run: {
          client: {
            result: true,
            prompt: ['statement, passbook, or certificate of cash investments covering the last 3 months'],
          },
          partner: {
            result: false,
            prompt: [],
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
