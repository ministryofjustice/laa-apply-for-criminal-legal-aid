RSpec.shared_examples 'an ownable investment requiring evidence' do
  subject(:rule) { described_class.new(crime_application) }

  let(:include_partner?) { true }
  let(:investments) { [] }

  before do
    allow(MeansStatus).to receive(:include_partner?).with(crime_application) { include_partner? }
  end

  let(:crime_application) do
    CrimeApplication.create!(
      investments: investments, applicant: Applicant.new, partner: Partner.new
    )
  end

  describe '.client' do
    subject(:predicate) { described_class.new(crime_application).client_predicate }

    let(:ownership_type) { OwnershipType::APPLICANT }
    let(:investments) { [Investment.new(investment_type:, ownership_type:)] }

    context 'when owned by client' do
      it { is_expected.to be true }
    end

    context 'when jointly owned' do
      let(:ownership_type) { OwnershipType::APPLICANT_AND_PARTNER }

      it { is_expected.to be true }
    end

    context 'with a different investment type' do
      let(:investment_type) { InvestmentType.values.find { |st| st != InvestmentType.new(super().to_sym) } }

      it { is_expected.to be false }
    end

    context 'when owned by applicant' do
      let(:ownership_type) { OwnershipType::PARTNER }

      it { is_expected.to be false }
    end
  end

  describe '.partner' do
    subject(:predicate) { described_class.new(crime_application).partner_predicate }

    let(:ownership_type) { OwnershipType::PARTNER }
    let(:investments) { [Investment.new(investment_type:, ownership_type:)] }

    context 'when owned by partner' do
      it { is_expected.to be true }

      context 'when partner is not included in means assessment' do
        let(:include_partner?) { true }

        it { is_expected.to be true }
      end
    end

    context 'when jointly owned' do
      let(:ownership_type) { OwnershipType::APPLICANT_AND_PARTNER }

      it { is_expected.to be true }
    end

    context 'with a different investment type' do
      let(:investment_type) { InvestmentType.values.find { |st| st != InvestmentType.new(super().to_sym) } }

      it { is_expected.to be false }
    end

    context 'when owned by client' do
      let(:ownership_type) { OwnershipType::APPLICANT }

      it { is_expected.to be false }
    end
  end

  describe '.other' do
    it { expect(subject.other_predicate).to be false }
  end

  describe '#to_h' do
    let(:investments) do
      [
        Investment.new(investment_type: investment_type, ownership_type: :applicant),
        Investment.new(investment_type: investment_type, ownership_type: :partner)
      ]
    end

    let(:expected_hash) do
      {
        id: described_class.name.demodulize,
        group: described_class.group,
        ruleset: nil,
        key: described_class.key,
        run: {
          client: {
            result: true,
            prompt: [expected_client_prompt]
          },
          partner: {
            result: true,
            prompt: [expected_partner_prompt]
          },
          other: {
            result: false,
            prompt: [],
          },
        }
      }
    end

    it { expect(rule.to_h).to eq expected_hash }
  end
end
