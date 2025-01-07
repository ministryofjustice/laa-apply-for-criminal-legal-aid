require 'rails_helper'

RSpec.describe Evidence::Rules::ChildcareCosts do
  subject { described_class.new(crime_application) }

  include_context 'serializable application'

  it { expect(described_class.key).to eq :outgoings_childcare_14 }
  it { expect(described_class.group).to eq :outgoings }
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
      let(:outgoings_payments) do
        [
          OutgoingsPayment.new(
            payment_type: OutgoingsPaymentType::CHILDCARE,
            frequency: PaymentFrequencyType::FOUR_WEEKLY,
            amount: 462.00,
          ),
        ]
      end

      it { is_expected.to be true }
    end

    context 'when threshold not met' do
      let(:outgoings_payments) do
        [
          OutgoingsPayment.new(
            payment_type: OutgoingsPaymentType::CHILDCARE,
            frequency: PaymentFrequencyType::ANNUALLY,
            amount: 6000,
          ),
        ]
      end

      it { is_expected.to be false }
    end

    context 'when there are no childcare payments' do
      let(:outgoings_payments) do
        [
          OutgoingsPayment.new(
            payment_type: OutgoingsPaymentType::RENT,
            frequency: PaymentFrequencyType::ANNUALLY,
            amount: (500.00 * 12),
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
    let(:outgoings_payments) do
      [
        OutgoingsPayment.new(
          payment_type: OutgoingsPaymentType::CHILDCARE,
          frequency: PaymentFrequencyType::MONTHLY,
          amount: 600.00,
        ),
      ]
    end

    let(:expected_hash) do
      {
        id: 'ChildcareCosts',
        group: :outgoings,
        ruleset: nil,
        key: :outgoings_childcare_14,
        run: {
          client: {
            result: true,
            prompt: ['proof of childcare costs, for example receipts or bank statements'],
          },
          partner: {
            result: true,
            prompt: ['proof of childcare costs, for example receipts or bank statements'],
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
