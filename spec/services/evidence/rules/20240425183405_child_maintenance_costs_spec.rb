require 'rails_helper'

RSpec.describe Evidence::Rules::ChildMaintenanceCosts do
  subject { described_class.new(crime_application) }

  it { expect(described_class.key).to eq :outgoings_maintenance_15 }
  it { expect(described_class.group).to eq :outgoings }
  it { expect(described_class.archived).to be false }
  it { expect(described_class.active?).to be true }

  include_context 'serializable application' do
    describe '.client' do
      subject { described_class.new(crime_application).client_predicate }

      context 'when threshold met' do
        let(:outgoings_payments) do
          [
            OutgoingsPayment.new(
              payment_type: OutgoingsPaymentType::MAINTENANCE,
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
              payment_type: OutgoingsPaymentType::MAINTENANCE,
              frequency: PaymentFrequencyType::ANNUALLY,
              amount: 6000,
            ),
          ]
        end

        it { is_expected.to be false }
      end

      context 'when there are no maintenance payments' do
        let(:outgoings_payments) do
          [
            OutgoingsPayment.new(
              payment_type: OutgoingsPaymentType::CHILDCARE,
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
            payment_type: OutgoingsPaymentType::MAINTENANCE,
            frequency: PaymentFrequencyType::MONTHLY,
            amount: 600.00
          ),
        ]
      end

      let(:expected_hash) do
        {
          id: 'ChildMaintenanceCosts',
          group: :outgoings,
          ruleset: nil,
          key: :outgoings_maintenance_15,
          run: {
            client: {
              result: true,
              prompt: ['proof of maintenance payments, for example bank statements showing payments'],
            },
            partner: {
              result: true,
              prompt: ['proof of maintenance payments, for example bank statements showing payments'],
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
end
