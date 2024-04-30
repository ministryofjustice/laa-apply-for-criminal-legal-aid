require 'rails_helper'

RSpec.describe Evidence::Rules::PrivatePensionIncome do
  subject { described_class.new(crime_application) }

  let(:crime_application) do
    CrimeApplication.create!(
      income:,
      income_payments:
    )
  end

  let(:income) { Income.new }
  let(:income_payments) { [] }

  it { expect(described_class.key).to eq :income_private_pension_5 }
  it { expect(described_class.group).to eq :income }
  it { expect(described_class.archived).to be false }
  it { expect(described_class.active?).to be true }

  describe 'THRESHOLD' do
    it 'is 1000.00 pounds' do
      expect(described_class::THRESHOLD).to eq 1000
    end
  end

  describe '.client' do
    subject { described_class.new(crime_application).client_predicate }

    context 'when threshold met' do
      let(:income_payments) do
        [
          IncomePayment.new(
            payment_type: IncomePaymentType::PRIVATE_PENSION,
            frequency: PaymentFrequencyType::FOUR_WEEKLY,
            amount: 923.10,
          ),
        ]
      end

      it { is_expected.to be true }
    end

    context 'when threshold not met' do
      let(:income_payments) do
        [
          IncomePayment.new(
            payment_type: IncomePaymentType::PRIVATE_PENSION,
            frequency: PaymentFrequencyType::ANNUALLY,
            amount: 12_000,
          ),
        ]
      end

      it { is_expected.to be false }
    end

    context 'when there are no private pension payments' do
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

  describe '.partner' do
    it { expect(subject.partner_predicate).to be false }
  end

  describe '.other' do
    it { expect(subject.other_predicate).to be false }
  end

  describe '#to_h' do
    let(:income_payments) do
      [
        IncomePayment.new(
          payment_type: IncomePaymentType::PRIVATE_PENSION,
          frequency: PaymentFrequencyType::MONTHLY,
          amount: 1000.01,
        ),
      ]
    end

    let(:expected_hash) do
      {
        id: 'PrivatePensionIncome',
        group: :income,
        ruleset: nil,
        key: :income_private_pension_5,
        run: {
          client: {
            result: true,
            prompt: ['either bank statements or their pension statement'],
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
