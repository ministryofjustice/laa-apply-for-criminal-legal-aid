require 'rails_helper'

RSpec.describe Evidence::Rules::AnyOtherIncome do
  subject { described_class.new(crime_application) }

  let(:crime_application) do
    CrimeApplication.create!(
      income: income,
      income_payments: income_payments,
      applicant: Applicant.new,
      partner: Partner.new
    )
  end
  let(:include_partner?) { true }

  let(:partner_other) do
    IncomePayment.new(
      payment_type: IncomePaymentType::OTHER,
      frequency: PaymentFrequencyType::MONTHLY,
      amount: 40.00,
      details: 'From my side-hustle',
      ownership_type: OwnershipType::PARTNER
    )
  end

  let(:client_other) do
    IncomePayment.new(
      payment_type: IncomePaymentType::OTHER,
      frequency: PaymentFrequencyType::MONTHLY,
      amount: 40.00,
      details: 'From my side-hustle'
    )
  end

  let(:income) { Income.new }
  let(:income_payments) { [client_other, partner_other] }

  before do
    allow(MeansStatus).to receive(:include_partner?).and_return(include_partner?)
  end

  it { expect(described_class.key).to eq :income_other_9 }
  it { expect(described_class.group).to eq :income }
  it { expect(described_class.archived).to be false }
  it { expect(described_class.active?).to be true }

  describe '.client' do
    subject { described_class.new(crime_application).client_predicate }

    context 'with other income' do
      it { is_expected.to be true }
    end

    context 'without other income details' do
      let(:client_other) do
        IncomePayment.new(
          payment_type: IncomePaymentType::OTHER,
          frequency: PaymentFrequencyType::MONTHLY,
          amount: 40.00,
          details: ''
        )
      end

      it { is_expected.to be false }
    end

    context 'without other income' do
      let(:income_payments) { [partner_other] }

      it { is_expected.to be false }
    end
  end

  describe '.partner' do
    subject(:predicate) { described_class.new(crime_application).partner_predicate }

    context 'with other income' do
      it { is_expected.to be true }

      context 'when partner is not included in means assessment' do
        let(:include_partner?) { false }

        it { is_expected.to be false }
      end
    end

    context 'when partner is not included in means assessment' do
      let(:include_partner?) { false }

      it { is_expected.to be false }
    end

    context 'without other income details' do
      let(:partner_other) do
        IncomePayment.new(
          payment_type: IncomePaymentType::OTHER,
          frequency: PaymentFrequencyType::MONTHLY,
          amount: 40.00,
          details: '',
          ownership_type: OwnershipType::PARTNER
        )
      end

      it { is_expected.to be false }
    end

    context 'without other income' do
      let(:income_payments) { [client_other] }

      it { is_expected.to be false }
    end
  end

  describe '.other' do
    it { expect(subject.other_predicate).to be false }
  end

  describe '#to_h' do
    let(:expected_hash) do
      {
        id: 'AnyOtherIncome',
        group: :income,
        ruleset: nil,
        key: :income_other_9,
        run: {
          client: {
            result: true,
            prompt: ['bank statements showing the income from other sources'],
          },
          partner: {
            result: true,
            prompt: ['bank statements showing the income from other sources'],
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
