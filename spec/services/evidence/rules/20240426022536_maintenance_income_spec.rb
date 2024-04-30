require 'rails_helper'

RSpec.describe Evidence::Rules::MaintenanceIncome do
  subject { described_class.new(crime_application) }

  let(:crime_application) do
    CrimeApplication.create!(
      income:,
      income_payments:
    )
  end

  let(:income) { Income.new }
  let(:income_payments) { [] }

  it { expect(described_class.key).to eq :income_maintenance_6 }
  it { expect(described_class.group).to eq :income }
  it { expect(described_class.archived).to be false }
  it { expect(described_class.active?).to be true }

  describe 'THRESHOLD' do
    it 'is 500.00 pounds' do
      expect(described_class::THRESHOLD).to eq 500
    end
  end

  describe '.client' do
    subject { described_class.new(crime_application).client_predicate }

    context 'when threshold met' do
      let(:income_payments) do
        [
          IncomePayment.new(
            payment_type: IncomePaymentType::MAINTENANCE,
            frequency: PaymentFrequencyType::WEEKLY,
            amount: 115.39,
          ),
        ]
      end

      it { is_expected.to be true }
    end

    context 'when threshold not met' do
      let(:income_payments) do
        [
          IncomePayment.new(
            payment_type: IncomePaymentType::MAINTENANCE,
            frequency: PaymentFrequencyType::ANNUALLY,
            amount: 6000,
          ),
        ]
      end

      it { is_expected.to be false }
    end

    context 'when there are no maintenance payments' do
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
          payment_type: IncomePaymentType::MAINTENANCE,
          frequency: PaymentFrequencyType::MONTHLY,
          amount: 500.01,
        ),
      ]
    end

    # rubocop:disable Layout/LineLength
    let(:expected_hash) do
      {
        id: 'MaintenanceIncome',
        group: :income,
        ruleset: nil,
        key: :income_maintenance_6,
        run: {
          client: {
            result: true,
            prompt: ['bank statements showing the maintenance payments, or the court order or Child Maintence Service agreement'],
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
    # rubocop:enable Layout/LineLength

    it { expect(subject.to_h).to eq expected_hash }
  end
end
