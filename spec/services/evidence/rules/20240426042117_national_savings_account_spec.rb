require 'rails_helper'

RSpec.describe Evidence::Rules::NationalSavingsAccount do
  it { expect(described_class.key).to eq :capital_nsa_19 }
  it { expect(described_class.group).to eq :capital }
  it { expect(described_class.archived).to be false }
  it { expect(described_class.active?).to be true }

  it_behaves_like 'an ownable saving requiring evidence' do
    let(:saving_type) { SavingType::NATIONAL_SAVINGS_OR_POST_OFFICE.to_sym }

    let(:expected_client_prompt) do
      'National Savings or Post Office account statements covering the last 3 months, for each account'
    end

    let(:expected_partner_prompt) { expected_client_prompt }
  end
end
