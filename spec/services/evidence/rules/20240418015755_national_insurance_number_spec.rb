require 'rails_helper'

RSpec.describe Evidence::Rules::NationalInsuranceNumber do
  subject(:rule) { described_class.new(crime_application) }

  include_context 'serializable application'

  let(:income_benefits) { [] }
  let(:case_type) { nil }
  let(:benefit_type) { nil }

  it { expect(described_class.key).to eq :national_insurance_32 }
  it { expect(described_class.group).to eq :none }
  it { expect(described_class.archived).to be false }
  it { expect(described_class.active?).to be true }

  describe '.client' do
    subject(:predicate) { rule.client_predicate }

    context 'when nino forthcoming' do
      before do
        allow(DWP::BenefitCheckStatusService).to receive(:call).and_return(
          BenefitCheckStatus::NO_CHECK_NO_NINO.to_s
        )
      end

      it { is_expected.to be true }
    end

    context 'when benefit check confirmed' do
      before do
        allow(DWP::BenefitCheckStatusService).to receive(:call).and_return(
          BenefitCheckStatus::CONFIRMED.to_s
        )
      end

      it { is_expected.to be false }
    end

    context 'when client has income benefits' do
      let(:income_benefits) do
        [
          IncomeBenefit.new(
            payment_type: IncomeBenefitType::CHILD,
            amount: 200,
            frequency: 'month',
            ownership_type: 'applicant'
          )
        ]
      end

      it { is_expected.to be true }
    end

    context 'client has no income benefits' do
      let(:income_benefits) do
        [
          IncomeBenefit.new(
            payment_type: IncomeBenefitType::CHILD,
            amount: 200,
            frequency: 'month',
            ownership_type: 'partner'
          )
        ]
      end

      it { is_expected.to be false }
    end
  end

  describe '.partner' do
    subject(:predicate) { rule.partner_predicate }

    context 'when nino forthcoming' do
      before do
        allow(DWP::BenefitCheckStatusService).to receive(:call).and_return(
          BenefitCheckStatus::NO_CHECK_NO_NINO.to_s
        )
      end

      it { is_expected.to be true }
    end

    context 'when benefit check confirmed' do
      before do
        allow(DWP::BenefitCheckStatusService).to receive(:call).and_return(
          BenefitCheckStatus::CONFIRMED.to_s
        )
      end

      it { is_expected.to be false }
    end

    context 'when partner has income benefits' do
      let(:income_benefits) do
        [
          IncomeBenefit.new(
            payment_type: IncomeBenefitType::CHILD,
            amount: 200,
            frequency: 'month',
            ownership_type: 'partner'
          )
        ]
      end

      it { is_expected.to be true }

      context 'when partner is not included in means' do
        let(:include_partner?) { false }

        it { is_expected.to be false }
      end
    end

    context 'when partner has no income benefits' do
      let(:income_benefits) do
        [
          IncomeBenefit.new(
            payment_type: IncomeBenefitType::CHILD,
            amount: 200,
            frequency: 'month',
            ownership_type: 'applicant'
          )
        ]
      end

      it { is_expected.to be false }
    end
  end

  describe '.other' do
    it { expect(subject.other_predicate).to be false }
  end

  describe '#to_h' do
    let(:income_benefits) do
      [
        IncomeBenefit.new(
          payment_type: IncomeBenefitType::CHILD,
          amount: 200,
          frequency: 'month',
          ownership_type: 'applicant'
        ),
        IncomeBenefit.new(
          payment_type: IncomeBenefitType::CHILD,
          amount: 200,
          frequency: 'month',
          ownership_type: 'partner'
        )
      ]
    end

    let(:expected_hash) do
      {
        id: 'NationalInsuranceNumber',
        group: :none,
        ruleset: nil,
        key: :national_insurance_32,
        run: {
          client: {
            result: true,
            prompt: ['their National Insurance number'],
          },
          partner: {
            result: true,
            prompt: ['their National Insurance number'],
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
