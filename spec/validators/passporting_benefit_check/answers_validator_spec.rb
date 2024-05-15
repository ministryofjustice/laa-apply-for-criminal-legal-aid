require 'rails_helper'

RSpec.describe PassportingBenefitCheck::AnswersValidator, type: :model do
  subject(:validator) { described_class.new(record) }

  let(:record) { instance_double(CrimeApplication, errors:, applicant:) }
  let(:errors) { double(:errors, empty?: false) }
  let(:applicant) { instance_double(Applicant, benefit_type:) }
  let(:benefit_type) { nil }
  let(:appeal_no_changes?) { false }
  let(:under18?) { false }
  let(:means_passported?) { false }

  before do
    allow(record).to receive_messages(appeal_no_changes?: appeal_no_changes?)
    allow(applicant).to receive_messages(under18?: under18?)
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
      let(:under18?) { true }

      it { is_expected.to be(false) }
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
