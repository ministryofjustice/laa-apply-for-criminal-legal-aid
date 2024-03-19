require 'rails_helper'

RSpec.describe SubmissionSerializer::Definitions::Investment do
  subject { described_class.generate(investments) }

  let(:investments) { [investment1, investment2] }

  let(:investment1) do
    Investment.new(
      investment_type: InvestmentType::BOND,
      description: 'About the Bond',
      value: 10_001,
      ownership_type: OwnershipType::APPLICANT
    )
  end

  let(:investment2) do
    Investment.new(
      investment_type: InvestmentType::UNIT_TRUST,
      description: 'About the Unit Trust',
      value: 21,
      ownership_type: OwnershipType::APPLICANT_AND_PARTNER
    )
  end

  let(:json_output) do
    [
      {
        investment_type: 'bond',
        description: 'About the Bond',
        value: 10_001,
        ownership_type: 'applicant'
      },
      {
        investment_type: 'unit_trust',
        description: 'About the Unit Trust',
        value: 21,
        ownership_type: 'applicant_and_partner'
      },
    ].as_json
  end

  describe '#generate' do
    it { expect(subject).to eq(json_output) }
  end
end
