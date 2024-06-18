require 'rails_helper'

RSpec.describe Evidence::Rules::TrustFund do
  subject { described_class.new(crime_application) }

  let(:crime_application) do
    CrimeApplication.create!(
      capital:,
    )
  end

  let(:capital) { Capital.new }
  let(:include_partner?) { true }

  before do
    allow(MeansStatus).to receive(:include_partner?).with(crime_application) { include_partner? }
  end

  it { expect(described_class.key).to eq :income_trust_10 }
  it { expect(described_class.group).to eq :income }
  it { expect(described_class.archived).to be false }
  it { expect(described_class.active?).to be true }

  describe '.client' do
    subject { described_class.new(crime_application).client_predicate }

    context 'when benefitting from trust fund and dividend' do
      let(:capital) do
        Capital.new(
          will_benefit_from_trust_fund: 'yes',
          trust_fund_yearly_dividend: 1
        )
      end

      it { is_expected.to be true }
    end

    context 'when benefitting from trust fund but no dividend' do
      let(:capital) do
        Capital.new(
          will_benefit_from_trust_fund: 'yes',
          trust_fund_yearly_dividend: nil
        )
      end

      it { is_expected.to be false }
    end

    context 'when not benefitting from trust fund but somehow has dividend' do
      let(:capital) do
        Capital.new(
          will_benefit_from_trust_fund: 'no',
          trust_fund_yearly_dividend: 10
        )
      end

      it { is_expected.to be false }
    end

    context 'when there is no capital' do
      let(:capital) { nil }

      it { is_expected.to be false }
    end
  end

  describe '.partner' do
    subject { described_class.new(crime_application).partner_predicate }

    let(:capital) do
      Capital.new(
        partner_will_benefit_from_trust_fund: 'yes', partner_trust_fund_yearly_dividend: 1
      )
    end

    context 'when benefitting from trust fund and dividend' do
      it { is_expected.to be true }

      context 'when partner is not included in means assessment' do
        let(:include_partner?) { false }

        it { is_expected.to be false }
      end
    end

    context 'when benefitting from trust fund but no dividend' do
      before do
        capital.partner_trust_fund_yearly_dividend = nil
      end

      it { is_expected.to be false }
    end

    context 'when not benefitting from trust fund but somehow has dividend' do
      before do
        capital.partner_trust_fund_yearly_dividend = 10
        capital.partner_will_benefit_from_trust_fund = 'no'
      end

      it { is_expected.to be false }
    end

    context 'when there is no capital' do
      let(:capital) { nil }

      it { is_expected.to be false }
    end
  end

  describe '.other' do
    it { expect(subject.other_predicate).to be false }
  end

  describe '#to_h' do
    let(:capital) do
      Capital.new(
        will_benefit_from_trust_fund: 'yes',
        trust_fund_yearly_dividend: 100,
        partner_will_benefit_from_trust_fund: 'yes',
        partner_trust_fund_yearly_dividend: 100
      )
    end

    let(:expected_hash) do
      {
        id: 'TrustFund',
        group: :income,
        ruleset: nil,
        key: :income_trust_10,
        run: {
          client: {
            result: true,
            prompt: ['the trust document, or a certified copy'],
          },
          partner: {
            result: true,
            prompt: ['the trust document, or a certified copy'],
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
