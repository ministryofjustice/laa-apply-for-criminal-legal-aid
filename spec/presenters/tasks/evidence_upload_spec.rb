require 'rails_helper'

RSpec.describe Tasks::EvidenceUpload do
  subject { described_class.new(crime_application:) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      to_param: '12345',
      applicant: applicant,
    )
  end

  let(:applicant) { instance_double Applicant }

  describe '#path' do
    it { expect(subject.path).to eq('/applications/12345/steps/evidence/upload') }
  end

  describe '#not_applicable?' do
    it { expect(subject.not_applicable?).to be(false) }
  end

  describe '#can_start?' do
    it { expect(subject.can_start?).to be(true) }
  end

  describe '#in_progress?' do
    it { expect(subject.in_progress?).to be(true) }
  end

  describe '#completed?' do
    before do
      allow_any_instance_of(SupportingEvidence::AnswersValidator).to receive(:complete?).and_return(evidence_complete)
    end

    context 'when evidence validation is true' do
      let(:evidence_complete) { true }

      it { expect(subject.completed?).to be(true) }
    end

    context 'when evidence validation is false' do
      let(:evidence_complete) { false }

      it { expect(subject.completed?).to be(false) }
    end
  end
end
