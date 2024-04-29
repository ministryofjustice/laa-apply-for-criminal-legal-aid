require 'rails_helper'

RSpec.describe Evidence::Rules::SelfAssessed do
  subject { described_class.new(crime_application) }

  let(:crime_application) do
    CrimeApplication.create!(
      outgoings:,
    )
  end

  let(:outgoings) { Outgoings.new }

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
