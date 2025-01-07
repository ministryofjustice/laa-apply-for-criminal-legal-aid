require 'rails_helper'

RSpec.describe Evidence::Rules::HousingCosts do
  subject { described_class.new(crime_application) }

  include_context 'serializable application'

  it { expect(described_class.key).to eq :outgoings_housing_11 }
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

    context 'when threshold met with mortgage' do
      let(:outgoings_payments) do
        [
          OutgoingsPayment.new(
            payment_type: OutgoingsPaymentType::MORTGAGE,
            frequency: PaymentFrequencyType::FOUR_WEEKLY,
            amount: 461.59,
          ),
        ]
      end

      it { is_expected.to be true }
    end

    context 'when threshold met with rent' do
      let(:outgoings_payments) do
        [
          OutgoingsPayment.new(
            payment_type: OutgoingsPaymentType::RENT,
            frequency: PaymentFrequencyType::ANNUALLY,
            amount: (501.00 * 12),
          ),
        ]
      end

      it { is_expected.to be true }
    end

    context 'when threshold met with board and lodging it is ignored' do
      let(:outgoings_payments) do
        [
          OutgoingsPayment.new(
            payment_type: OutgoingsPaymentType::BOARD_AND_LODGING,
            frequency: PaymentFrequencyType::WEEKLY,
            amount: 115.99,
          ),
        ]
      end

      it { is_expected.to be false }
    end

    context 'when exactly at threshold' do
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

    context 'when there are no housing payments' do
      let(:outgoings_payments) do
        [
          OutgoingsPayment.new(
            payment_type: OutgoingsPaymentType::COUNCIL_TAX,
            frequency: PaymentFrequencyType::FORTNIGHTLY,
            amount: 231.00,
          ),
        ]
      end

      it { is_expected.to be false }
    end

    context 'when threshold not met' do
      let(:outgoings_payments) do
        [
          OutgoingsPayment.new(
            payment_type: OutgoingsPaymentType::MORTGAGE,
            frequency: PaymentFrequencyType::MONTHLY,
            amount: 0.11,
          ),
          OutgoingsPayment.new(
            payment_type: OutgoingsPaymentType::RENT,
            frequency: PaymentFrequencyType::FORTNIGHTLY,
            amount: 50.02,
          ),
          OutgoingsPayment.new(
            payment_type: OutgoingsPaymentType::BOARD_AND_LODGING,
            frequency: PaymentFrequencyType::ANNUALLY,
            amount: 300.50,
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
          payment_type: OutgoingsPaymentType::MORTGAGE,
          frequency: PaymentFrequencyType::FOUR_WEEKLY,
          amount: 600.00,
        ),
      ]
    end

    let(:expected_hash) do
      {
        id: 'HousingCosts',
        group: :outgoings,
        ruleset: nil,
        key: :outgoings_housing_11,
        run: {
          client: {
            result: true,
            prompt: ['their rental, tenancy agreement or mortgage statement'],
          },
          partner: {
            result: true,
            prompt: ['their rental, tenancy agreement or mortgage statement'],
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
