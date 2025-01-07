require 'rails_helper'

RSpec.describe Evidence::Rules::CouncilTaxPayments do
  subject { described_class.new(crime_application) }

  include_context 'serializable application'

  it { expect(described_class.key).to eq :outgoings_counciltax_12 }
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
            payment_type: OutgoingsPaymentType::COUNCIL_TAX,
            frequency: PaymentFrequencyType::FORTNIGHTLY,
            amount: 231.00,
          ),
        ]
      end

      it { is_expected.to be true }
    end

    context 'when threshold not met' do
      let(:outgoings_payments) do
        [
          OutgoingsPayment.new(
            payment_type: OutgoingsPaymentType::COUNCIL_TAX,
            frequency: PaymentFrequencyType::ANNUALLY,
            amount: 6000,
          ),
        ]
      end

      it { is_expected.to be false }
    end

    context 'when there are no council tax payments' do
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
          payment_type: OutgoingsPaymentType::COUNCIL_TAX,
          frequency: PaymentFrequencyType::MONTHLY,
          amount: 600.00,
        ),
      ]
    end

    let(:expected_hash) do
      {
        id: 'CouncilTaxPayments',
        group: :outgoings,
        ruleset: nil,
        key: :outgoings_counciltax_12,
        run: {
          client: {
            result: true,
            prompt: ['their Council Tax statement'],
          },
          partner: {
            result: true,
            prompt: ['their Council Tax statement'],
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
