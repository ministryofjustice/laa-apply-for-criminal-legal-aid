require 'rails_helper'

RSpec.describe Evidence::Rules::SelfAssessed do
  subject { described_class.new(crime_application) }

  let(:crime_application) do
    CrimeApplication.create!(
      outgoings:,
      income:,
    )
  end

  let(:outgoings) { Outgoings.new }
  let(:income) { Income.new }
  let(:include_partner?) { true }

  before do
    allow(MeansStatus).to receive(:include_partner?).and_return(include_partner?)
  end

  it { expect(described_class.key).to eq :income_p60_sa302_2 }
  it { expect(described_class.group).to eq :income }
  it { expect(described_class.archived).to be false }
  it { expect(described_class.active?).to be true }

  describe '.client' do
    subject { described_class.new(crime_application).client_predicate }

    context 'when high tax earner' do
      let(:outgoings) { Outgoings.new(income_tax_rate_above_threshold: 'yes') }

      it { is_expected.to be true }
    end

    context 'when not high tax earner' do
      let(:outgoings) { Outgoings.new(income_tax_rate_above_threshold: 'no') }

      it { is_expected.to be false }
    end

    context 'when applicant has paid a self assessment tax bill' do
      let(:income) { Income.new(applicant_self_assessment_tax_bill: 'yes') }

      it { is_expected.to be true }
    end

    context 'when applicant has not paid a self assessment tax bill' do
      let(:income) { Income.new(applicant_self_assessment_tax_bill: 'no') }

      it { is_expected.to be false }
    end
  end

  describe '.partner' do
    subject { described_class.new(crime_application).partner_predicate }

    before do
      outgoings.partner_income_tax_rate_above_threshold = above_threshold
    end

    context 'when high tax earner' do
      let(:above_threshold) { 'yes' }

      it { is_expected.to be true }

      context 'when partner is not included in means assessment' do
        let(:include_partner?) { false }

        it { is_expected.to be false }
      end
    end

    context 'when not high tax earner' do
      let(:above_threshold) { 'no' }

      it { is_expected.to be false }
    end

    context 'when we do not know if high tax earner' do
      let(:above_threshold) { nil }

      it { is_expected.to be false }
    end

    context 'when partner has paid a self assessment tax bill' do
      let(:income) { Income.new(partner_self_assessment_tax_bill: 'yes') }
      let(:above_threshold) { 'no' }

      it { is_expected.to be true }
    end
  end

  describe '.other' do
    it { expect(subject.other_predicate).to be false }
  end

  describe '#to_h' do
    let(:outgoings) do
      Outgoings.new(
        income_tax_rate_above_threshold: 'yes',
        partner_income_tax_rate_above_threshold: 'yes',
      )
    end

    let(:expected_hash) do
      {
        id: 'SelfAssessed',
        group: :income,
        ruleset: nil,
        key: :income_p60_sa302_2,
        run: {
          client: {
            result: true,
            prompt: ['either their P60 or their Self Assessment tax calculation (SA302)'],
          },
          partner: {
            result: true,
            prompt: ['either their P60 or their Self Assessment tax calculation (SA302)'],
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
