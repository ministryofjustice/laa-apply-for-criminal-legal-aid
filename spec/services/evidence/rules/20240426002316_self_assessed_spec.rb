require 'rails_helper'

RSpec.describe Evidence::Rules::SelfAssessed do
  subject { described_class.new(crime_application) }

  include_context 'serializable application'

  let(:outgoings) { crime_application.outgoings }

  it { expect(described_class.key).to eq :income_p60_sa302_2 }
  it { expect(described_class.group).to eq :income }
  it { expect(described_class.archived).to be false }
  it { expect(described_class.active?).to be true }

  describe '.client' do
    subject { described_class.new(crime_application).client_predicate }

    before do
      crime_application.outgoings.income_tax_rate_above_threshold = above_threshold
      crime_application.income.applicant_self_assessment_tax_bill = self_assessed
    end

    let(:self_assessed) { nil }
    let(:above_threshold) { nil }

    context 'when high tax earner' do
      let(:above_threshold) { 'yes' }

      it { is_expected.to be true }
    end

    context 'when not high tax earner' do
      let(:above_threshold) { 'no' }

      it { is_expected.to be false }
    end

    context 'when applicant has paid a self assessment tax bill' do
      let(:client_employed?) { true }
      let(:self_assessed) { 'yes' }

      it { is_expected.to be true }
    end

    context 'when applicant has not paid a self assessment tax bill' do
      let(:client_employed?) { true }
      let(:self_assessed) { 'no' }

      it { is_expected.to be false }
    end
  end

  describe '.partner' do
    subject { described_class.new(crime_application).partner_predicate }

    before do
      crime_application.outgoings.partner_income_tax_rate_above_threshold = above_threshold
      crime_application.income.partner_self_assessment_tax_bill = self_assessed
    end

    let(:self_assessed) { nil }
    let(:above_threshold) { nil }

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
      let(:partner_employed?) { true }
      let(:self_assessed) { 'yes' }

      it { is_expected.to be true }
    end

    context 'when partner has paid a self assessment tax bill and no long means assessed' do
      let(:partner_employed?) { true }
      let(:include_partner?) { false }

      let(:self_assessed) { 'yes' }

      it { is_expected.to be false }
    end

    context 'when partner has paid a self assessment tax bill but no longer employed' do
      let(:partner_employed?) { false }
      let(:self_assessed) { 'yes' }

      it { is_expected.to be false }
    end
  end

  describe '.other' do
    it { expect(subject.other_predicate).to be false }
  end

  describe '#to_h' do
    before do
      crime_application.outgoings.income_tax_rate_above_threshold = 'yes'
      crime_application.outgoings.partner_income_tax_rate_above_threshold = 'yes'
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
