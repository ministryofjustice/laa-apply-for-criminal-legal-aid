require 'rails_helper'

RSpec.describe Evidence::Rules::BenefitsRecipient do
  subject(:rule) { described_class.new(crime_application) }

  include_context 'serializable application'

  it { expect(described_class.key).to eq :income_benefits_0b }
  it { expect(described_class.group).to eq :income }
  it { expect(described_class.archived).to be false }
  it { expect(described_class.active?).to be true }

  describe '.client' do
    subject(:predicate) { rule.client_predicate }

    context 'when applicant has a passported benefit' do
      before do
        applicant.benefit_type = 'jsa'
        applicant.benefit_check_result = true
        applicant.has_nino = 'yes'
        applicant.nino = 'QQ123456A'
      end

      context 'when DWP check passed' do
        it { is_expected.to be false }
      end

      context 'when DWP check failed' do
        before do
          applicant.benefit_check_result = false
          applicant.confirm_dwp_result = 'no'
          applicant.has_benefit_evidence = 'yes'
        end

        it { is_expected.to be true }

        context 'when they are passported on age' do
          let(:age_passported?) { true }

          it { is_expected.to be false }
        end

        context 'when they have no benefit evidence' do
          before do
            applicant.has_benefit_evidence = 'no'
          end

          it { is_expected.to be false }
        end

        context 'when they confirm the DWP result' do
          before do
            applicant.confirm_dwp_result = 'yes'
          end

          it { is_expected.to be false }
        end
      end
    end
  end

  describe '.partner' do
    subject(:predicate) { rule.partner_predicate }

    context 'when partner has a passported benefit' do
      before do
        applicant.benefit_type = 'none'
        partner.benefit_type = 'jsa'
        partner.benefit_check_result = true
        partner.has_nino = 'yes'
        partner.nino = 'QQ123456A'
      end

      context 'when DWP check passed' do
        it { is_expected.to be false }
      end

      context 'when DWP check failed' do
        before do
          partner.benefit_check_result = false
          partner.confirm_dwp_result = 'no'
          partner.has_benefit_evidence = 'yes'
        end

        it { is_expected.to be true }

        context 'when applicant has a passporting benefit' do
          before do
            applicant.benefit_type = 'jsa'
          end

          it { is_expected.to be false }
        end

        context 'when they are passported on age' do
          let(:age_passported?) { true }

          it { is_expected.to be false }
        end

        context 'when they have no benefit evidence' do
          before do
            partner.has_benefit_evidence = 'no'
          end

          it { is_expected.to be false }
        end

        context 'when they confirm the DWP result' do
          before do
            partner.confirm_dwp_result = 'yes'
          end

          it { is_expected.to be false }
        end
      end
    end
  end

  describe '.other' do
    subject(:predicate) { rule.partner_predicate }

    it { is_expected.to be false }
  end

  describe '#to_h', skip: 'Double check expected behavior of benefit check status service' do
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

    before do
      applicant.benefit_type = applicant_benefit
      applicant.nino = 'QQ123456A'
      applicant.benefit_check_result = false
      applicant.confirm_dwp_result = 'no'
      applicant.has_benefit_evidence = 'yes'
      partner.benefit_type = 'jsa'
      partner.nino = 'AA123456A'
      partner.benefit_check_result = false
      partner.confirm_dwp_result = 'no'
      partner.has_benefit_evidence = 'yes'
    end

    context 'when applicant is benefit recipient' do
      let(:applicant_benefit) { 'jsa' }

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
      let(:applicant_benefit) { 'none' }

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
