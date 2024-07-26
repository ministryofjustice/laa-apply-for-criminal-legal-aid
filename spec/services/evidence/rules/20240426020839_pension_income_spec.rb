require 'rails_helper'

RSpec.describe Evidence::Rules::PrivatePensionIncome do
  subject { described_class.new(crime_application) }

  include_context 'serializable application'

  let(:partner_pension) do
    IncomePayment.new(
      payment_type: IncomePaymentType::PRIVATE_PENSION,
      frequency: PaymentFrequencyType::MONTHLY,
      amount: 1000.01,
      ownership_type: OwnershipType::PARTNER
    )
  end

  let(:client_pension) do
    IncomePayment.new(
      payment_type: IncomePaymentType::PRIVATE_PENSION,
      frequency: PaymentFrequencyType::FOUR_WEEKLY,
      amount: 923.10
    )
  end

  let(:income_payments) { [client_pension, partner_pension] }

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
      it { is_expected.to be true }
    end

    context 'when threshold not met' do
      before do
        client_pension.frequency = PaymentFrequencyType::ANNUALLY
        client_pension.amount = 1_200_000
      end

      it { is_expected.to be false }
    end

    context 'when there are no private pension payments' do
      let(:income_payments) { [partner_pension] }

      it { is_expected.to be false }
    end
  end

  describe '.partner' do
    subject { described_class.new(crime_application).partner_predicate }

    context 'when threshold met' do
      it { is_expected.to be true }
    end

    context 'when partner is not included in means assessment' do
      let(:include_partner?) { false }

      it { is_expected.to be false }
    end

    context 'when threshold not met' do
      before do
        partner_pension.frequency = PaymentFrequencyType::MONTHLY
        partner_pension.amount = 100_000
      end

      it { is_expected.to be false }
    end

    context 'when they have no private pension payments' do
      let(:income_payments) { [client_pension] }

      it { is_expected.to be false }
    end
  end

  describe '.other' do
    it { expect(subject.other_predicate).to be false }
  end

  describe '#to_h' do
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
            result: true,
            prompt: ['either bank statements or their pension statement'],
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
