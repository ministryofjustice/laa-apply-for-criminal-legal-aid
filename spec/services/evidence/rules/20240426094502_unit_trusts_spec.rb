require 'rails_helper'

RSpec.describe Evidence::Rules::UnitTrusts do
  subject { described_class.new(crime_application) }

  let(:crime_application) do
    CrimeApplication.create!(
      investments:
    )
  end

  let(:investments) { [] }

  it { expect(described_class.key).to eq :capital_unit_trusts_27 }
  it { expect(described_class.group).to eq :capital }
  it { expect(described_class.archived).to be false }
  it { expect(described_class.active?).to be true }

  describe '.client' do
    subject { described_class.new(crime_application).client_predicate }

    context 'with unit trust investments' do
      let(:investments) { [Investment.new(investment_type: 'unit_trust')] }

      it { is_expected.to be true }
    end

    context 'without unit trust investments' do
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
    let(:investments) { [Investment.new(investment_type: 'unit_trust')] }

    let(:expected_hash) do
      {
        id: 'UnitTrusts',
        group: :capital,
        ruleset: nil,
        key: :capital_unit_trusts_27,
        run: {
          client: {
            result: true,
            prompt: ['certificate or statement for each Unit Trust investment'],
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
