require 'rails_helper'

RSpec.describe Evidence::Rules::InvestmentBonds do
  it { expect(described_class.key).to eq :capital_investment_bonds_28 }
  it { expect(described_class.group).to eq :capital }
  it { expect(described_class.archived).to be false }
  it { expect(described_class.active?).to be true }

  it_behaves_like 'an ownable investment requiring evidence' do
    let(:investment_type) { InvestmentType::BOND.to_sym }

    let(:expected_client_prompt) do
      'certificate or statement for each investment bond'
    end

    let(:expected_partner_prompt) { expected_client_prompt }
  end
end
