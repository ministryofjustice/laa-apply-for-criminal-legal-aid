require 'rails_helper'

RSpec.describe Evidence::Rules::NationalSavingsAccount do
  subject { described_class.new(crime_application) }

  let(:crime_application) do
    CrimeApplication.create!(
      savings:
    )
  end

  let(:savings) { [] }

  it { expect(described_class.key).to eq :capital_nsa_19 }
  it { expect(described_class.group).to eq :capital }
  it { expect(described_class.archived).to be false }
  it { expect(described_class.active?).to be true }

  describe '.client' do
    subject { described_class.new(crime_application).client_predicate }

    context 'with national savings account' do
      let(:savings) { [Saving.new(saving_type: 'national_savings_or_post_office')] }

      it { is_expected.to be true }
    end

    context 'with national savings accounts' do
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
    let(:savings) { [Saving.new(saving_type: 'national_savings_or_post_office')] }

    let(:expected_hash) do
      {
        id: 'NationalSavingsAccount',
        group: :capital,
        ruleset: nil,
        key: :capital_nsa_19,
        run: {
          client: {
            result: true,
            prompt: ['National Savings or Post Office account statements covering the last 3 months, for each account'],
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
