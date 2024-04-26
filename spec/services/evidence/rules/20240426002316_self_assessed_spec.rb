require 'rails_helper'

RSpec.describe Evidence::Rules::SelfAssessed do
  subject { described_class.new(crime_application) }

  let(:crime_application) do
    CrimeApplication.create!(
      income:,
      outgoings:,
    )
  end

  let(:income) { Income.new }
  let(:outgoings) { Outgoings.new }

  it { expect(described_class.key).to eq :income_p60_sa302_2 }
  it { expect(described_class.group).to eq :income }
  it { expect(described_class.archived).to be false }
  it { expect(described_class.active?).to be true }

  describe '.client' do
    subject { described_class.new(crime_application).client_predicate }

    context 'when self-assesment employment status' do
      let(:income) { Income.new(employment_status: [EmploymentStatus::DIRECTOR]) }
      let(:outgoings) { Outgoings.new(income_tax_rate_above_threshold: 'no') }

      it { is_expected.to be true }
    end

    context 'when high tax earner' do
      let(:income) { Income.new(employment_status: [EmploymentStatus::EMPLOYED]) }
      let(:outgoings) { Outgoings.new(income_tax_rate_above_threshold: 'yes') }

      it { is_expected.to be true }
    end

    context 'when employed and not high tax earner' do
      let(:income) { Income.new(employment_status: [EmploymentStatus::EMPLOYED]) }
      let(:outgoings) { Outgoings.new(income_tax_rate_above_threshold: 'no') }

      it { is_expected.to be false }
    end

    context 'when mixed employment status' do
      let(:income) { Income.new(employment_status: %w[director employed]) }
      let(:outgoings) { Outgoings.new(income_tax_rate_above_threshold: nil) }

      it { is_expected.to be true }
    end
  end

  describe '.partner' do
    it { expect(subject.partner_predicate).to be false }
  end

  describe '.other' do
    it { expect(subject.other_predicate).to be false }
  end

  describe '#to_h' do
    let(:outgoings) { Outgoings.new(income_tax_rate_above_threshold: 'yes') }

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
