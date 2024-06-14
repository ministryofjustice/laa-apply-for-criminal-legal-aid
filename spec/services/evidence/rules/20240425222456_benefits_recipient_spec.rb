require 'rails_helper'

RSpec.describe Evidence::Rules::BenefitsRecipient do
  subject(:rule) { described_class.new(crime_application) }

  let(:crime_application) do
    CrimeApplication.create!(applicant:, partner:, partner_detail:)
  end

  let(:applicant) do
    Applicant.new(
      has_benefit_evidence: 'yes',
      benefit_type: 'jsa',
      benefit_check_result: false,
      date_of_birth: '2000-01-01',
      nino: 'QQ123456A'
    )
  end

  let(:partner) do
    Partner.new(
      has_benefit_evidence: 'yes',
      benefit_type: 'jsa',
      benefit_check_result: false,
      date_of_birth: '2000-01-02',
      nino: 'QQ123456B'
    )
  end

  let(:partner_detail) { PartnerDetail.new(involvement_in_case: 'none') }

  it { expect(described_class.key).to eq :income_benefits_0b }
  it { expect(described_class.group).to eq :income }
  it { expect(described_class.archived).to be false }
  it { expect(described_class.active?).to be true }

  describe '.client' do
    subject(:predicate) { rule.client_predicate }

    context 'when applicant has a passported benefit' do
      context 'and DWP check failed' do
        it { is_expected.to be true }
      end

      context 'and DWP check passed' do
        before { applicant.benefit_check_result = true }

        it { is_expected.to be false }
      end

      context 'when they are passpoted on age' do
        before { applicant.date_of_birth = 16.years.ago.to_date }

        it { is_expected.to be false }
      end

      context 'when they have no benefit evidence' do
        before { applicant.has_benefit_evidence = 'no' }

        it { is_expected.to be false }
      end
    end

    context 'when there is no applicant' do
      let(:applicant) { nil }

      it { is_expected.to be false }
    end
  end

  describe '.partner' do
    subject(:predicate) { rule.partner_predicate }

    context 'when the applicant has a passporting benefit' do
      it { is_expected.to be false }
    end

    context 'when the applicant does not have a passporting benefit' do
      before do
        applicant.benefit_type = 'none'
      end

      context 'when the partner has a passporting benefit' do
        context 'and DWP check failed' do
          it { is_expected.to be true }
        end

        context 'and DWP check passed' do
          before { partner.benefit_check_result = true }

          it { is_expected.to be false }
        end

        context 'when the applicant is passpoted on age' do
          before { applicant.date_of_birth = 16.years.ago.to_date }

          it { is_expected.to be false }
        end

        context 'when they have no benefit evidence' do
          before { partner.has_benefit_evidence = 'no' }

          it { is_expected.to be false }
        end
      end
    end

    context 'when there is no partner' do
      let(:partner) { nil }

      it { is_expected.to be false }
    end
  end

  describe '.other' do
    subject(:predicate) { rule.partner_predicate }

    it { is_expected.to be false }
  end

  describe '#to_h' do
    let(:expected_hash) do
      {
        id: 'BenefitsRecipient',
        group: :income,
        ruleset: nil,
        key: :income_benefits_0b,
        run: {
          client: {
            result: expected_applicant_result,
            prompt: expected_applicant_prompt,
          },
          partner: {
            result: expected_partner_result,
            prompt: expected_partner_prompt,
          },
          other: {
            result: false,
            prompt: [],
          },
        }
      }
    end

    context 'when applicant is benefit recipient' do
      let(:expected_applicant_prompt) do
        ['benefit book or notice of entitlement or letter from Jobcentre Plus ' \
         'stating the benefits your client receives']
      end

      let(:expected_partner_prompt) { [] }
      let(:expected_applicant_result) { true }
      let(:expected_partner_result) { false }

      it { expect(rule.to_h).to eq expected_hash }
    end

    context 'when partner is benefit recipient' do
      before do
        applicant.benefit_type = 'none'
      end

      let(:expected_partner_prompt) do
        ['benefit book or notice of entitlement or letter from Jobcentre Plus ' \
         'stating the benefits the partner receives']
      end

      let(:expected_applicant_prompt) { [] }
      let(:expected_applicant_result) { false }
      let(:expected_partner_result) { true }

      it { expect(rule.to_h).to eq expected_hash }
    end
  end
end
