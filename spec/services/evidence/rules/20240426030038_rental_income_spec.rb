require 'rails_helper'

RSpec.describe Evidence::Rules::RentalIncome do
  subject { described_class.new(crime_application) }

  let(:crime_application) do
    CrimeApplication.create!(
      income: income,
      income_payments: income_payments,
      applicant: Applicant.new,
      partner: Partner.new
    )
  end

  let(:partner_rent) do
    IncomePayment.new(
      payment_type: IncomePaymentType::RENT,
      frequency: PaymentFrequencyType::MONTHLY,
      amount: 2000.00,
      ownership_type: OwnershipType::PARTNER
    )
  end

  let(:client_rent) do
    IncomePayment.new(
      payment_type: IncomePaymentType::RENT,
      frequency: PaymentFrequencyType::MONTHLY,
      amount: 2000.00
    )
  end

  let(:income) { Income.new }
  let(:income_payments) { [client_rent, partner_rent] }
  let(:include_partner?) { true }

  before do
    allow(MeansStatus).to receive_messages(
      include_partner?: include_partner?, full_means_required?: true
    )
  end

  it { expect(described_class.key).to eq :income_rent_8 }
  it { expect(described_class.group).to eq :income }
  it { expect(described_class.archived).to be false }
  it { expect(described_class.active?).to be true }

  describe '.client' do
    subject { described_class.new(crime_application).client_predicate }

    context 'with rental income' do
      it { is_expected.to be true }
    end

    context 'without rental income' do
      let(:income_payments) { [partner_rent] }

      it { is_expected.to be false }
    end
  end

  describe '.partner' do
    subject(:predicate) { described_class.new(crime_application).partner_predicate }

    context 'with rental income' do
      it { is_expected.to be true }

      context 'when partner is not included in means assessment' do
        let(:include_partner?) { false }

        it { is_expected.to be false }
      end
    end

    context 'without rental income' do
      let(:income_payments) { [client_rent] }

      it { is_expected.to be false }
    end
  end

  describe '.other' do
    it { expect(subject.other_predicate).to be false }
  end

  describe '#to_h' do
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
            result: true,
            prompt: ['bank statements showing the rental income'],
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
