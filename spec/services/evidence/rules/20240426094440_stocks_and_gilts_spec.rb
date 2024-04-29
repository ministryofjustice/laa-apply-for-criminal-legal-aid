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
      let(:investments) { [Investment.new(investment_type: 'stock', ownership_type: :applicant)] }

      it { is_expected.to be true }
    end

    context 'without stocks and gilts investments' do
      let(:investments) { [Investment.new(investment_type: 'other', ownership_type: :applicant)] }

      it { is_expected.to be false }
    end

    context 'when not owned by client' do
      let(:investments) { [Investment.new(investment_type: 'share', ownership_type: :partner)] }

      it { is_expected.to be false }
    end
  end

  describe '.partner' do
    subject { described_class.new(crime_application).partner_predicate }

    context 'with stocks and gilts investments' do
      let(:investments) { [Investment.new(investment_type: 'stock', ownership_type: :partner)] }

      it { is_expected.to be true }
    end

    context 'without stocks and gilts investments' do
      let(:investments) { [Investment.new(investment_type: 'other', ownership_type: :partner)] }

      it { is_expected.to be false }
    end

    context 'when not owned by partner' do
      let(:investments) { [Investment.new(investment_type: 'share', ownership_type: :applicant)] }

      it { is_expected.to be false }
    end
  end

  describe '.other' do
    it { expect(subject.other_predicate).to be false }
  end

  describe '#to_h' do
    let(:investments) do
      [
        Investment.new(investment_type: 'stock', ownership_type: :applicant),
        Investment.new(investment_type: 'stock', ownership_type: :partner),
      ]
    end

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
            result: true,
            prompt: ['certificate or statement for each stock, gilt or government bond'],
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
