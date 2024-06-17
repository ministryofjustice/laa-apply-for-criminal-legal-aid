require 'rails_helper'

RSpec.describe Evidence::Rules::PremiumBonds do
  subject { described_class.new(crime_application) }

  let(:crime_application) do
    CrimeApplication.create!(
      capital:
    )
  end

  let(:capital) { Capital.new }

  before do
    allow(MeansStatus).to receive(:include_partner?).with(crime_application)
                                                    .and_return(true)
  end

  it { expect(described_class.key).to eq :capital_premium_bonds_21 }
  it { expect(described_class.group).to eq :capital }
  it { expect(described_class.archived).to be false }
  it { expect(described_class.active?).to be true }

  describe '.client' do
    subject { described_class.new(crime_application).client_predicate }

    context 'with premium bonds saving' do
      let(:capital) { Capital.new(has_premium_bonds: 'yes') }

      it { is_expected.to be true }
    end

    context 'without premium bonds saving' do
      let(:capital) { Capital.new(has_premium_bonds: 'no') }

      it { is_expected.to be false }
    end

    context 'when premium bonds saving is not set' do
      let(:capital) { Capital.new(has_premium_bonds: nil) }

      it { is_expected.to be false }
    end
  end

  describe '.partner' do
    subject { described_class.new(crime_application).partner_predicate }

    context 'with premium bonds saving' do
      let(:capital) { Capital.new(partner_has_premium_bonds: 'yes') }

      it { is_expected.to be true }
    end

    context 'without premium bonds saving' do
      let(:capital) { Capital.new(partner_has_premium_bonds: 'no') }

      it { is_expected.to be false }
    end

    context 'when premium bonds saving is not set' do
      let(:capital) { Capital.new(partner_has_premium_bonds: nil) }

      it { is_expected.to be false }
    end
  end

  describe '.other' do
    it { expect(subject.other_predicate).to be false }
  end

  describe '#to_h' do
    let(:capital) { Capital.new(has_premium_bonds: 'yes', partner_has_premium_bonds: 'yes') }

    let(:expected_hash) do
      {
        id: 'PremiumBonds',
        group: :capital,
        ruleset: nil,
        key: :capital_premium_bonds_21,
        run: {
          client: {
            result: true,
            prompt: ['copy of the Premium Savings Bonds or a Bond record'],
          },
          partner: {
            result: true,
            prompt: ['copy of the Premium Savings Bonds or a Bond record'],
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
