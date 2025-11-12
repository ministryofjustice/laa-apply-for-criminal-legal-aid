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
        applicant.has_nino = 'yes'
        applicant.nino = 'QQ123456A'
        applicant.has_benefit_evidence = has_benefit_evidence

        allow(DWP::BenefitCheckStatusService).to receive(:call).and_return(benefit_check_status)
      end

      context 'when DWP check passed' do
        let(:benefit_check_status) { BenefitCheckStatus::CONFIRMED.to_s }
        let(:has_benefit_evidence) { nil }

        it { is_expected.to be false }

        context 'when they have no benefit evidence' do
          # This is not a scenario that would occur via application routing, but might be if a user
          # changes the details to undergo the check and previously went through a different dwp route
          let(:has_benefit_evidence) { 'no' }

          it { is_expected.to be false }
        end
      end

      context 'when DWP result is `No`' do
        let(:benefit_check_status) { BenefitCheckStatus::NO_RECORD_FOUND.to_s }
        let(:has_benefit_evidence) { 'yes' }

        it { is_expected.to be true }

        context 'when they are passported on age' do
          let(:age_passported?) { true }

          it { is_expected.to be false }
        end

        context 'when they have no benefit evidence' do
          let(:has_benefit_evidence) { 'no' }

          it { is_expected.to be false }
        end
      end

      context 'when DWP result is undetermined' do
        let(:benefit_check_status) { BenefitCheckStatus::UNDETERMINED.to_s }
        let(:has_benefit_evidence) { 'yes' }

        it { is_expected.to be true }

        context 'when they have no benefit evidence' do
          let(:has_benefit_evidence) { 'no' }

          it { is_expected.to be false }
        end
      end

      context 'when DWP checker is unavailable' do
        let(:benefit_check_status) { BenefitCheckStatus::CHECKER_UNAVAILABLE.to_s }
        let(:has_benefit_evidence) { 'yes' }

        it { is_expected.to be true }

        context 'when they have no benefit evidence' do
          let(:has_benefit_evidence) { 'no' }

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
        partner.has_nino = 'yes'
        partner.nino = 'QQ123456A'
        partner.has_benefit_evidence = has_benefit_evidence

        allow(DWP::BenefitCheckStatusService).to receive(:call).and_return(benefit_check_status)
      end

      context 'when DWP check passed' do
        let(:benefit_check_status) { BenefitCheckStatus::CONFIRMED.to_s }
        let(:has_benefit_evidence) { nil }

        it { is_expected.to be false }

        context 'when they have no benefit evidence' do
          # This is not a scenario that would occur via application routing, but might be if a user
          # changes the details to undergo the check and previously went through a different dwp route
          let(:has_benefit_evidence) { 'no' }

          it { is_expected.to be false }
        end
      end

      context 'when DWP result is `No`' do
        let(:benefit_check_status) { BenefitCheckStatus::NO_RECORD_FOUND.to_s }
        let(:has_benefit_evidence) { 'yes' }

        it { is_expected.to be true }

        context 'when they are passported on age' do
          let(:age_passported?) { true }

          it { is_expected.to be false }
        end

        context 'when they have no benefit evidence' do
          let(:has_benefit_evidence) { 'no' }

          it { is_expected.to be false }
        end
      end

      context 'when DWP result is undetermined' do
        let(:benefit_check_status) { BenefitCheckStatus::UNDETERMINED.to_s }
        let(:has_benefit_evidence) { 'yes' }

        it { is_expected.to be true }

        context 'when they have no benefit evidence' do
          let(:has_benefit_evidence) { 'no' }

          it { is_expected.to be false }
        end
      end

      context 'when DWP checker is unavailable' do
        let(:benefit_check_status) { BenefitCheckStatus::CHECKER_UNAVAILABLE.to_s }
        let(:has_benefit_evidence) { 'yes' }

        it { is_expected.to be true }

        context 'when they have no benefit evidence' do
          let(:has_benefit_evidence) { 'no' }

          it { is_expected.to be false }
        end
      end
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

    before do
      applicant.has_benefit_evidence = applicant_has_evidence
      partner.has_benefit_evidence = partner_has_evidence

      allow(DWP::BenefitCheckStatusService).to receive(:call).and_return(
        BenefitCheckStatus::UNDETERMINED.to_s
      )
    end

    context 'when applicant is benefit recipient' do
      let(:applicant_has_evidence) { 'yes' }
      let(:partner_has_evidence) { nil }

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
      let(:applicant_has_evidence) { nil }
      let(:partner_has_evidence) { 'yes' }

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
