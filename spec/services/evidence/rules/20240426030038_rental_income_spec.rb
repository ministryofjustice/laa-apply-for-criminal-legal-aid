require 'rails_helper'

RSpec.describe Evidence::Rules::RentalIncome do
  subject { described_class.new(crime_application) }

  let(:crime_application) do
    CrimeApplication.create!(
      income:,
      income_payments:
    )
  end

  let(:income) { Income.new }
  let(:income_payments) { [] }

  it { expect(described_class.key).to eq :income_rent_8 }
  it { expect(described_class.group).to eq :income }
  it { expect(described_class.archived).to be false }
  it { expect(described_class.active?).to be true }

  describe '.client' do
    subject { described_class.new(crime_application).client_predicate }

    context 'with rental income' do
      let(:income_payments) do
        [
          IncomePayment.new(
            payment_type: IncomePaymentType::RENT,
            frequency: PaymentFrequencyType::MONTHLY,
            amount: 2000.00,
          ),
        ]
      end

      it { is_expected.to be true }
    end

    context 'without rental income' do
      let(:income_payments) do
        [
          IncomePayment.new(
            payment_type: IncomePaymentType::STUDENT_LOAN_GRANT,
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
          payment_type: IncomePaymentType::RENT,
          frequency: PaymentFrequencyType::ANNUALLY,
          amount: 20_000.00,
        ),
      ]
    end

    let(:expected_hash) do
      {
        id: 'RentalIncome',
        group: :income,
        ruleset: nil,
        key: :income_rent_8,
        run: {
          client: {
            result: true,
            prompt: ['bank statements showing the rental income'],
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
