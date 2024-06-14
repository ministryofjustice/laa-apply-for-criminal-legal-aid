require 'rails_helper'

RSpec.describe Evidence::Rules::OwnShares do
  it { expect(described_class.key).to eq :capital_shares_24 }
  it { expect(described_class.group).to eq :capital }
  it { expect(described_class.archived).to be false }
  it { expect(described_class.active?).to be true }

  it_behaves_like 'an ownable investment requiring evidence' do
    let(:investment_type) { InvestmentType::SHARE.to_sym }

    let(:expected_client_prompt) do
      'share certificate or latest dividend counterfoil for each company they hold shares in'
    end

    let(:expected_partner_prompt) { expected_client_prompt }
  end
end
