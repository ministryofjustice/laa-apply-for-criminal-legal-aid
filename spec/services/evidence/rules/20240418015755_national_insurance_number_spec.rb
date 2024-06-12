
require 'rails_helper'

RSpec.describe Evidence::Rules::NationalInsuranceNumber do
  subject { described_class.new(crime_application) }

  let(:benefit_type) { nil }
  let(:dob) { nil }
  let(:nino) { nil }
  let(:applicant) {
    Applicant.new(
      date_of_birth: Date.new(1995, 5, 12),
      nino: nil,
      has_nino: 'no',
      will_enter_nino: 'no',
      benefit_type: benefit_type,
    )
  }
  
  let(:case_type) { nil }
  let(:kase) { Case.new(case_type:) }
  let(:income_benefits) { [] }

  let(:crime_application) do
    CrimeApplication.create!(
      applicant: applicant,
      date_stamp: DateTime.now,
      case: kase,
      income_benefits: income_benefits
    )
  end

  it { expect(described_class.key).to eq :national_insurance_32 }
  it { expect(described_class.group).to eq :none }
  it { expect(described_class.archived).to be false }
  it { expect(described_class.active?).to be true }

  describe '.client' do
    subject { described_class.new(crime_application).client_predicate }

    context 'when applicant is over 18 without a NINO' do
      let(:dob) { Date.new(1995, 5, 12) }

      context 'when the case type is `indictable`' do
        let(:case_type) { CaseType::INDICTABLE.to_s }

        it { is_expected.to be true }
      end

      context 'when the case type is `already_in_crown_court`' do
        let(:case_type) { CaseType::ALREADY_IN_CROWN_COURT.to_s }

        it { is_expected.to be true }
      end

      context 'when the applicant receives a passporting benefit' do
        let(:benefit_type) { BenefitType::JSA }

        it { is_expected.to be true }
      end

      context 'when the applicant receives a non-passporting benefit' do
        let(:income_benefits) { [IncomeBenefit.new(payment_type: IncomeBenefitType::CHILD, amount: 200)] }

        it { is_expected.to be true }
      end
    end

    context 'when applicant is under 18' do
      let(:dob) { Date.new(2015, 5, 12) }

      it { is_expected.to be false }
    end

    context 'when NINO has been entered' do
      let(:nino) { 'AB123456A' }

      it { is_expected.to be false }
    end
  end

  describe '.partner' do
    let(:partner_detail) do
      instance_double(PartnerDetail, involvement_in_case: 'none')
    end

    let(:partner) do
      instance_double(
        Partner,
        over_18_at_date_stamp?: true,
        nino: nil,
        partner?: true
      )
    end 

    before do
      allow(crime_application).to receive_messages(partner_detail:, partner:)
    end

    it { expect(subject.partner_predicate).to be false }

    context 'when partner nino forthcoming' do
      # sets the applicant benefit type to 'none'
      let(:benefit_type) { 'none' }

      before do
        allow(partner).to receive_messages(
          benefit_type: 'jsa',
          has_nino: 'no',
          will_enter_nino: 'no'
        )
      end

      it { expect(subject.partner_predicate).to be true }
    end

    context 'when partner has Income Benefits' do
      let(:income_benefits) { [IncomeBenefit.new(payment_type: IncomeBenefitType::CHILD, amount: 200, ownership_type: OwnershipType::PARTNER)] }
    
      it { expect(subject.partner_predicate).to be true }
    end
    
    context 'when just applicant has Income Benefits' do
      let(:income_benefits) { [IncomeBenefit.new(payment_type: IncomeBenefitType::CHILD, amount: 200, ownership_type: OwnershipType::APPLICANT)] }
    
      it { expect(subject.partner_predicate).to be false }
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
