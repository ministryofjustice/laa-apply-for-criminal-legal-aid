require 'rails_helper'

RSpec.describe Evidence::Rules::InterestAndInvestments do
  subject { described_class.new(crime_application) }

  let(:crime_application) do
    CrimeApplication.create!(
      income:,
      income_payments:
    )
  end

  let(:income) { Income.new }
  let(:income_payments) { [] }

  it { expect(described_class.key).to eq :income_investments_7 }
  it { expect(described_class.group).to eq :income }
  it { expect(described_class.archived).to be false }
  it { expect(described_class.active?).to be true }

  describe '.client' do
    subject { described_class.new(crime_application).client_predicate }

    context 'with interest or income from savings or investments payments' do
      let(:income_payments) do
        [
          IncomePayment.new(
            payment_type: IncomePaymentType::INTEREST_INVESTMENT,
            frequency: PaymentFrequencyType::WEEKLY,
            amount: 20.00,
          ),
        ]
      end

      it { is_expected.to be true }
    end

    context 'without any interest or income from savings payments' do
      let(:income_payments) do
        [
          IncomePayment.new(
            payment_type: IncomePaymentType::RENT,
            frequency: PaymentFrequencyType::FORTNIGHTLY,
            amount: 500.00,
          ),
        ]
      end

      it { is_expected.to be false }
    end
  end

  describe '.other' do
    it { expect(subject.other_predicate).to be false }
  end

  describe '#to_h' do
    let(:income_payments) do
      [
        IncomePayment.new(
          payment_type: IncomePaymentType::INTEREST_INVESTMENT,
          frequency: PaymentFrequencyType::MONTHLY,
          amount: 500.01,
        ),
      ]
    end

    let(:expected_hash) do
      {
        id: 'InterestAndInvestments',
        group: :income,
        ruleset: nil,
        key: :income_investments_7,
        run: {
          client: {
            result: true,
            prompt: ['bank statements showing interest from their savings or investments'],
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
