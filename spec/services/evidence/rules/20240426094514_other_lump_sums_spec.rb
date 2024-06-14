require 'rails_helper'

RSpec.describe Evidence::Rules::OtherLumpSums do
  it { expect(described_class.key).to eq :capital_other_lump_sums_29 }
  it { expect(described_class.group).to eq :capital }
  it { expect(described_class.archived).to be false }
  it { expect(described_class.active?).to be true }

  it_behaves_like 'an ownable investment requiring evidence' do
    let(:investment_type) { InvestmentType::OTHER.to_sym }

    let(:expected_client_prompt) do
      'statement, passbook or certificate of other lump sum investments, covering transactions for the last 6 months'
    end

    let(:expected_partner_prompt) { expected_client_prompt }
  end
end
