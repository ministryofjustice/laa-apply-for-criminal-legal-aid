require 'rails_helper'

RSpec.describe PassportingBenefitCheck::AnswersValidator, type: :model do
  subject(:validator) { described_class.new(record) }

  let(:record) {
    instance_double(CrimeApplication, errors: errors, applicant: applicant, partner: partner,
   partner_detail: partner_detail, non_means_tested?: false)
  }
  let(:errors) { double(:errors, empty?: false) }
  let(:applicant) { instance_double(Applicant, benefit_type: benefit_type, arc: nil) }
  let(:benefit_type) { nil }
  let(:appeal_no_changes?) { false }
  let(:age_passported?) { false }
  let(:means_passported?) { false }
  let(:partner) { nil }
  let(:partner_detail) { nil }

  before do
    allow(record).to receive_messages(
      appeal_no_changes?: appeal_no_changes?,
      age_passported?: age_passported?,
      is_means_tested: true
    )

    allow_any_instance_of(Passporting::MeansPassporter).to receive(:call).and_return(means_passported?)
  end

  describe '#applicable?' do
    subject(:applicable?) { validator.applicable? }

    it { is_expected.to be(true) }

    context 'when appeal no changes' do
      let(:appeal_no_changes?) { true }

      it { is_expected.to be(false) }
    end

    context 'when under 18' do
      let(:age_passported?) { true }

      it { is_expected.to be(false) }
    end

    context 'when non_means_tested' do
      before do
        allow(record).to receive(:non_means_tested?).and_return(true)
      end

      it { is_expected.to be(false) }
    end

    context 'when the applicant has an arc number' do
      before do
        allow(applicant).to receive(:arc).and_return('ABC12/345678/A')
      end

      context 'when there is no partner' do
        it { is_expected.to be(false) }
      end

      context 'when the partner has an arc number' do
        let(:partner) { instance_double(Partner, arc: 'ABC12/345678/A') }

        it { is_expected.to be(false) }
      end

      context 'when there is a partner with no arc number' do
        let(:partner) { instance_double(Partner, nino: 'AB123456A', arc: nil) }

        it { is_expected.to be(true) }
      end
    end
  end

  describe '#complete?' do
    subject(:complete?) { validator.complete? }

    context 'when passporting benefit not known' do
      let(:benefit_type) { nil }

      it { is_expected.to be(false) }
    end

    context 'when has passporting benefit' do
      let(:benefit_type) { BenefitType::JSA.to_s }

      context 'when means passported' do
        let(:means_passported?) { true }

        it { is_expected.to be(true) }
      end

      context 'when has no passporting benefit' do
        let(:benefit_type) { 'none' }

        it { is_expected.to be(true) }
      end

      context 'when evidence of passporting benefit forthcoming' do
        before do
          allow(validator).to receive(:evidence_of_passporting_means_forthcoming?).and_return(true)
        end

        it { is_expected.to be(true) }
      end

      context 'applicant doing means assessment instead' do
        before do
          allow(validator).to receive_messages(evidence_of_passporting_means_forthcoming?: false,
                                               means_assessment_as_benefit_evidence?: true)
        end

        it { is_expected.to be(true) }
      end
    end

    context 'when the partner is the benefit check recipient' do
      let(:partner_detail) { double(PartnerDetail, involvement_in_case: 'none') }
      let(:benefit_type) { BenefitType::NONE.to_s }
      let(:partner) {
        double(Partner, id: '234', benefit_type: BenefitType::UNIVERSAL_CREDIT.to_s,
                             nino: 'AB123456A', has_benefit_evidence: 'yes', arc: nil)
      }

      it { is_expected.to be(true) }
    end
  end

  describe '#validate' do
    subject(:validate) { validator.validate }

    context 'when not applicable' do
      before do
        allow(validator).to receive(:applicable?).and_return(false)
      end

      it 'does not add errors' do
        expect(errors).not_to receive(:add)
        validate
      end
    end

    context 'when applicable' do
      before do
        allow(validator).to receive(:applicable?).and_return(true)
      end

      it 'adds errors to :appeal_details when incomplete' do
        allow(validator).to receive(:complete?).and_return(false)
        expect(errors).to receive(:add).with(:benefit_type, :incomplete)
        expect(errors).to receive(:add).with(:base, :incomplete_records)

        validate
      end

      it 'does not add errors when complete' do
        allow(validator).to receive(:complete?).and_return(true)
        expect(errors).not_to receive(:add)

        validate
      end
    end
  end
end
