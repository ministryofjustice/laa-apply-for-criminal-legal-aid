require 'rails_helper'

RSpec.describe Evidence::Rules::ShareIsa do
  it { expect(described_class.key).to eq :capital_share_isa_26 }
  it { expect(described_class.group).to eq :capital }
  it { expect(described_class.archived).to be false }
  it { expect(described_class.active?).to be true }

  it_behaves_like 'an ownable investment requiring evidence' do
    let(:investment_type) { InvestmentType::SHARE_ISA.to_sym }

    let(:expected_client_prompt) do
      'certificate or statement for each Share ISA'
    end

    let(:expected_partner_prompt) { expected_client_prompt }
  end
end
