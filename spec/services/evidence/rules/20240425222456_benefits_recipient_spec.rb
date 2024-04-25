require 'rails_helper'

RSpec.describe Evidence::Rules::BenefitsRecipient do
  subject { described_class.new(crime_application) }

  let(:crime_application) do
    CrimeApplication.create!(
      income:,
      income_benefits:,
    )
  end

  let(:income) { Income.new }
  let(:income_benefits) { [] }

  it { expect(described_class.key).to eq :income_employed_0b }
  it { expect(described_class.group).to eq :income }
  it { expect(described_class.archived).to be false }
  it { expect(described_class.active?).to be true }

  describe '.client' do
    subject { described_class.new(crime_application).client_predicate }

    context 'with income benefit' do
      let(:income) { Income.new(has_no_income_benefits: 'no') }
      let(:income_benefits) do
        [
          IncomeBenefit.new(
            payment_type: IncomeBenefitType::CHILD,
            frequency: PaymentFrequencyType::FOUR_WEEKLY,
            amount: 50.00,
          ),
        ]
      end

      it { is_expected.to be true }
    end

    # Cannot rely on `has_no_income_benefits` alone because it
    # is only set when user selected 'none' option
    context 'without has_no_income_benefits set' do
      let(:income) { Income.new(has_no_income_benefits: nil) }
      let(:income_benefits) do
        [
          IncomeBenefit.new(
            payment_type: IncomeBenefitType::INCAPACITY,
            frequency: PaymentFrequencyType::ANNUALLY,
            amount: 50.00,
          ),
        ]
      end

      it { is_expected.to be true }
    end

    context 'with has_no_income_benefits but without income_benefit entries' do
      let(:income) { Income.new(has_no_income_benefits: 'no') }

      it { is_expected.to be true }
    end

    context 'without has_no_income_benefits or any income_benefit entries' do
      let(:income) { Income.new(has_no_income_benefits: nil) }
      let(:income_benefits) { [] }

      it { is_expected.to be false }
    end

    context 'when there is no income' do
      let(:income) { nil }

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
    let(:income) { Income.new(has_no_income_benefits: 'no') }
    let(:income_benefits) do
      [
        IncomeBenefit.new(
          payment_type: IncomeBenefitType::JSA,
          frequency: PaymentFrequencyType::MONTHLY,
          amount: 100.00,
        ),
      ]
    end

    # rubocop:disable Layout/LineLength
    let(:expected_hash) do
      {
        id: 'BenefitsRecipient',
        group: :income,
        ruleset: nil,
        key: :income_employed_0b,
        run: {
          client: {
            result: true,
            prompt: ['benefit book or notice of entitlement or letter from Jobcentre Plus stating the benefits your client receives'],
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
