require 'rails_helper'

RSpec.describe Evidence::Rules::BuildingSocietyAccounts do
  it { expect(described_class.key).to eq :capital_building_society_accounts_17 }
  it { expect(described_class.group).to eq :capital }
  it { expect(described_class.archived).to be false }
  it { expect(described_class.active?).to be true }

  it_behaves_like 'an ownable saving requiring evidence' do
    let(:saving_type) { SavingType::BUILDING_SOCIETY.to_sym }

    let(:expected_client_prompt) do
      'building society statement or passbook showing transactions for the last 3 months, for each account'
    end

    let(:expected_partner_prompt) { expected_client_prompt }
  end
end
