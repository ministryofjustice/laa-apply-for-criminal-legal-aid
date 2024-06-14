require 'rails_helper'

RSpec.describe Evidence::Rules::CashInvestments do
  it { expect(described_class.key).to eq :capital_cash_investments_20 }
  it { expect(described_class.group).to eq :capital }
  it { expect(described_class.archived).to be false }
  it { expect(described_class.active?).to be true }

  it_behaves_like 'an ownable saving requiring evidence' do
    let(:saving_type) { SavingType::OTHER.to_sym }

    let(:expected_client_prompt) do
      'statement, passbook, or certificate of cash investments covering the last 3 months'
    end

    let(:expected_partner_prompt) { expected_client_prompt }
  end
end
