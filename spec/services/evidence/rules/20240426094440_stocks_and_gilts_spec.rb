require 'rails_helper'

RSpec.describe Evidence::Rules::StocksAndGilts do
  subject { described_class.new(crime_application) }

  let(:crime_application) do
    CrimeApplication.create!(
      investments:
    )
  end

  let(:investments) { [] }

  it { expect(described_class.key).to eq :capital_stocks_gilts_23 }
  it { expect(described_class.group).to eq :capital }
  it { expect(described_class.archived).to be false }
  it { expect(described_class.active?).to be true }

  describe '.client' do
    subject { described_class.new(crime_application).client_predicate }

    context 'with stocks and gilts investments' do
      let(:investments) { [Investment.new(investment_type: 'stock')] }

      it { is_expected.to be true }
    end

    context 'without stocks and gilts investments' do
      let(:investments) { [Investment.new(investment_type: 'other')] }

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
    let(:investments) { [Investment.new(investment_type: 'stock')] }

    let(:expected_hash) do
      {
        id: 'StocksAndGilts',
        group: :capital,
        ruleset: nil,
        key: :capital_stocks_gilts_23,
        run: {
          client: {
            result: true,
            prompt: ['certificate or statement for each stock, gilt or government bond'],
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
