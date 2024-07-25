require 'rails_helper'

RSpec.describe Evidence::Rules::CashIsa do
  subject { described_class.new(crime_application) }

  include_context 'serializable application'

  it { expect(described_class.key).to eq :capital_cash_isa_18 }
  it { expect(described_class.group).to eq :capital }
  it { expect(described_class.archived).to be false }
  it { expect(described_class.active?).to be true }

  it_behaves_like 'an ownable saving requiring evidence' do
    let(:saving_type) { SavingType::CASH_ISA.to_sym }

    let(:expected_client_prompt) do
      'cash ISA statements showing transactions for the last 3 months, for each account'
    end

    let(:expected_partner_prompt) { expected_client_prompt }
  end
end
