require 'rails_helper'

RSpec.describe Evidence::Rules::NationalInsuranceNumber do
  subject(:rule) { described_class.new(crime_application) }

  let(:crime_application) do
    CrimeApplication.create!(
      applicant: applicant,
      partner: partner,
      partner_detail: partner_detail,
      date_stamp: DateTime.now,
      case: Case.new(case_type:),
      income_benefits: income_benefits
    )
  end
  let(:income_benefits) { [] }
  let(:case_type) { nil }
  let(:applicant) {
    Applicant.new(
      date_of_birth: '1995-05-01',
      nino: nil,
      has_nino: 'no',
      will_enter_nino: 'no',
      benefit_type: benefit_type,
    )
  }
  let(:partner_detail) { nil }
  let(:partner) { nil }
  let(:benefit_type) { nil }

  it { expect(described_class.key).to eq :national_insurance_32 }
  it { expect(described_class.group).to eq :none }
  it { expect(described_class.archived).to be false }
  it { expect(described_class.active?).to be true }

  describe '.client' do
    subject(:predicate) { rule.client_predicate }

    context 'when applicant is over 18 without a NINO' do
      context 'when the case type is `indictable`' do
        let(:case_type) { CaseType::INDICTABLE.to_s }

        it { is_expected.to be true }
      end

      context 'when the case type is `already_in_crown_court`' do
        let(:case_type) { CaseType::ALREADY_IN_CROWN_COURT.to_s }

        it { is_expected.to be true }
      end

      context 'when the case type is `summary only`' do
        let(:case_type) { CaseType::SUMMARY_ONLY.to_s }

        it { is_expected.to be false }
      end

      context 'when the applicant receives a passporting benefit' do
        let(:benefit_type) { BenefitType::JSA }

        it { is_expected.to be true }
      end

      context 'when the applicant receives a non-passporting benefit' do
        let(:income_benefits) do
          [IncomeBenefit.new(payment_type: IncomeBenefitType::CHILD, amount: 200)]
        end

        it { is_expected.to be true }
      end
    end

    context 'when applicant is under 18' do
      before { applicant.date_of_birth = 15.years.ago.to_date }

      it { is_expected.to be false }
    end

    context 'when NINO has been entered' do
      before { applicant.nino = 'AB123456A' }

      it { is_expected.to be false }
    end
  end

  describe '.partner' do
    subject(:predicate) { rule.partner_predicate }

    let(:partner_detail) { PartnerDetail.new(involvement_in_case: 'none') }
    let(:partner) { Partner.new(date_of_birth: '2000-01-01') }
    let(:ownership_type) { OwnershipType::APPLICANT }

    let(:income_benefits) do
      [
        IncomeBenefit.new(
          payment_type: IncomeBenefitType::CHILD,
          amount: 200,
          ownership_type: ownership_type
        )
      ]
    end

    it { is_expected.to be false }

    context 'when partner nino forthcoming' do
      let(:benefit_type) { 'none' }

      before do
        partner.benefit_type = 'jsa'
        partner.has_nino = 'no'
        partner.will_enter_nino = 'no'
      end

      it { is_expected.to be true }
    end

    context 'when partner has Income Benefits' do
      let(:ownership_type) { OwnershipType::PARTNER }

      it { is_expected.to be true }
    end

    context 'when just applicant has Income Benefits' do
      let(:ownership_type) { OwnershipType::APPLICANT }

      it { is_expected.to be false }
    end
  end

  describe '.other' do
    it { expect(subject.other_predicate).to be false }
  end

  describe '#to_h' do
    let(:dob) { Date.new(1995, 5, 12) }
    let(:case_type) { CaseType::INDICTABLE.to_s }

    let(:expected_hash) do
      {
        id: 'NationalInsuranceNumber',
        group: :none,
        ruleset: nil,
        key: :national_insurance_32,
        run: {
          client: {
            result: true,
            prompt: ['their National Insurance number'],
          },
          partner: {
            result: false,
            prompt: [],
          },
          other: {
            result: false,
            prompt: [],
          },
        }
      }
    end

    it { expect(subject.to_h).to eq expected_hash }
  end
end
