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
      let(:investments) { [Investment.new(investment_type: 'unit_trust', ownership_type: :applicant)] }

      it { is_expected.to be true }
    end

    context 'without unit trust investments' do
      let(:investments) { [Investment.new(investment_type: 'stock', ownership_type: :applicant)] }

      it { is_expected.to be false }
    end

    context 'when not owned by client' do
      let(:investments) { [Investment.new(investment_type: 'unit_trust', ownership_type: :partner)] }

      it { is_expected.to be false }
    end
  end

  describe '.partner' do
    subject { described_class.new(crime_application).partner_predicate }

    context 'with unit trust investments' do
      let(:investments) { [Investment.new(investment_type: 'unit_trust', ownership_type: :partner)] }

      it { is_expected.to be true }
    end

    context 'without unit trust investments' do
      let(:investments) { [Investment.new(investment_type: 'stock', ownership_type: :partner)] }

      it { is_expected.to be false }
    end

    context 'when not owned by partner' do
      let(:investments) { [Investment.new(investment_type: 'unit_trust', ownership_type: :applicant)] }

      it { is_expected.to be false }
    end
  end

  describe '.other' do
    it { expect(subject.other_predicate).to be false }
  end

  describe '#to_h' do
    let(:investments) do
      [
        Investment.new(investment_type: 'unit_trust', ownership_type: :applicant),
        Investment.new(investment_type: 'unit_trust', ownership_type: :partner),
      ]
    end

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
            result: true,
            prompt: ['certificate or statement for each Unit Trust investment'],
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
