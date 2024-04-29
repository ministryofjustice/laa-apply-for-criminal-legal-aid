require 'rails_helper'

RSpec.describe Evidence::Rules::TrustFund do
  subject { described_class.new(crime_application) }

  let(:crime_application) do
    CrimeApplication.create!(
      capital:,
    )
  end

  let(:capital) { Capital.new }

  it { expect(described_class.key).to eq :income_trust_10 }
  it { expect(described_class.group).to eq :capital }
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
    it { expect(subject.partner_predicate).to be false }
  end

  describe '.other' do
    it { expect(subject.other_predicate).to be false }
  end

  describe '#to_h' do
    let(:capital) do
      Capital.new(
        will_benefit_from_trust_fund: 'yes',
        trust_fund_yearly_dividend: 100
      )
    end

    let(:expected_hash) do
      {
        id: 'TrustFund',
        group: :capital,
        ruleset: nil,
        key: :income_trust_10,
        run: {
          client: {
            result: true,
            prompt: ['the trust document, or a certified copy'],
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

    it { expect(subject.to_h).to eq expected_hash }
  end
end
