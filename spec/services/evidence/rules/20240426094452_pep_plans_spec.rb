require 'rails_helper'

RSpec.describe Evidence::Rules::PepPlans do
  subject { described_class.new(crime_application) }

  let(:crime_application) do
    CrimeApplication.create!(
      investments:
    )
  end

  let(:investments) { [] }

  it { expect(described_class.key).to eq :capital_pep_25 }
  it { expect(described_class.group).to eq :capital }
  it { expect(described_class.archived).to be false }
  it { expect(described_class.active?).to be true }

  describe '.client' do
    subject { described_class.new(crime_application).client_predicate }

    context 'with pep investments' do
      let(:investments) { [Investment.new(investment_type: 'pep')] }

      it { is_expected.to be true }
    end

    context 'without pep investments' do
      let(:investments) { [Investment.new(investment_type: 'stock')] }

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
    let(:investments) { [Investment.new(investment_type: 'pep')] }

    let(:expected_hash) do
      {
        id: 'PepPlans',
        group: :capital,
        ruleset: nil,
        key: :capital_pep_25,
        run: {
          client: {
            result: true,
            prompt: ['certificate or statement for each Personal Equity Plan investment'],
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
