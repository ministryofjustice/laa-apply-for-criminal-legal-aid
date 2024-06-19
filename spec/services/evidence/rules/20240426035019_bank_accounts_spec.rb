require 'rails_helper'

RSpec.describe Evidence::Rules::BankAccounts do
  it { expect(described_class.key).to eq :capital_bank_accounts_16 }
  it { expect(described_class.group).to eq :capital }
  it { expect(described_class.archived).to be false }
  it { expect(described_class.active?).to be true }

  it_behaves_like 'an ownable saving requiring evidence' do
    let(:saving_type) { SavingType::BANK.to_sym }

    let(:expected_client_prompt) do
      'bank statements for the last 3 months, for each account, ' \
        'including any joint account with a partner'
    end

    let(:expected_partner_prompt) do
      'bank statements for the last 3 months, for each account, ' \
        'including any joint account held with your client'
    end
  end
end
