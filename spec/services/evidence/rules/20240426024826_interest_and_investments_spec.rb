require 'rails_helper'

RSpec.describe Evidence::Rules::InterestAndInvestments do
  subject { described_class.new(crime_application) }

  let(:crime_application) do
    CrimeApplication.create!(
      income: income,
      income_payments: income_payments,
      applicant: Applicant.new,
      partner: Partner.new
    )
  end

  let(:partner_investments) do
    IncomePayment.new(
      payment_type: IncomePaymentType::INTEREST_INVESTMENT,
      frequency: PaymentFrequencyType::MONTHLY,
      amount: 20.00,
      ownership_type: OwnershipType::PARTNER
    )
  end

  let(:client_investments) do
    IncomePayment.new(
      payment_type: IncomePaymentType::INTEREST_INVESTMENT,
      frequency: PaymentFrequencyType::WEEKLY,
      amount: 2.00
    )
  end

  let(:income) { Income.new }
  let(:income_payments) { [client_investments, partner_investments] }
  let(:include_partner?) { true }

  before do
    allow(MeansStatus).to receive(:include_partner?).and_return(include_partner?)
  end

  it { expect(described_class.key).to eq :income_investments_7 }
  it { expect(described_class.group).to eq :income }
  it { expect(described_class.archived).to be false }
  it { expect(described_class.active?).to be true }

  describe '.client' do
    subject { described_class.new(crime_application).client_predicate }

    context 'with interest or income from savings or investments payments' do
      it { is_expected.to be true }
    end

    context 'without any interest or income from savings payments' do
      let(:income_payments) { [partner_investments] }

      it { is_expected.to be false }
    end
  end

  describe '.partner' do
    subject(:predicate) { described_class.new(crime_application).partner_predicate }

    context 'with interest or income from savings or investments payments' do
      it { is_expected.to be true }

      context 'when partner is not included in means assessment' do
        let(:include_partner?) { false }

        it { is_expected.to be false }
      end
    end

    context 'without any interest or income from savings payments' do
      let(:income_payments) { [client_investments] }

      it { is_expected.to be false }
    end
  end

  describe '.other' do
    it { expect(subject.other_predicate).to be false }
  end

  describe '#to_h' do
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
            result: true,
            prompt: ['bank statements showing interest from their savings or investments'],
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
