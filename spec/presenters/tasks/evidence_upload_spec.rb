require 'rails_helper'

RSpec.describe Tasks::EvidenceUpload do
  subject { described_class.new(crime_application:) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      to_param: '12345',
      documents: documents,
    )
  end

  let(:documents) { [] }

  describe '#path' do
    it { expect(subject.path).to eq('/applications/12345/steps/evidence/upload') }
  end

  describe '#not_applicable?' do
    before do
      allow(
        subject
      ).to receive(:fulfilled?).with(Tasks::ClientDetails).and_return(true)

      allow_any_instance_of(
        Evidence::Requirements
      ).to receive(:none?).and_return(no_evidence_required)
    end

    context 'when evidence is deemed required' do
      let(:no_evidence_required) { false }

      it { expect(subject.not_applicable?).to be(false) }
    end

    context 'when evidence is deemed not required' do
      let(:no_evidence_required) { true }

      it { expect(subject.not_applicable?).to be(true) }
    end
  end

  describe '#can_start?' do
    # We assume the completeness of the Case Details here, as
    # their statuses are tested in its own spec, no need to repeat
    before do
      allow(
        subject
      ).to receive(:fulfilled?).with(Tasks::CaseDetails).and_return(case_details_fulfilled)

      allow(crime_application).to receive(:pse?).and_return(pse?)
    end

    let(:pse?) { false }

    context 'when the Case Details task has been completed' do
      let(:case_details_fulfilled) { true }

      it { expect(subject.can_start?).to be(true) }
    end

    context 'when the Case Details task has not been completed yet' do
      let(:case_details_fulfilled) { false }

      it { expect(subject.can_start?).to be(false) }

      context 'but the application is pse' do
        let(:pse?) { true }

        it { expect(subject.can_start?).to be(true) }
      end
    end
  end

  describe '#in_progress?' do
    context 'when there are any documents' do
      let(:documents) { ['doc'] }

      it { expect(subject.in_progress?).to be(true) }
    end

    context 'when there are no documents yet' do
      let(:documents) { [] }

      it { expect(subject.in_progress?).to be(false) }
    end
  end

  describe '#completed?' do
    let(:documents) { double(stored: scoped_documents) }

    context 'when there are any stored documents' do
      let(:scoped_documents) { ['stored_doc'] }

      it { expect(subject.completed?).to be(true) }
    end

    context 'when there are no stored documents yet' do
      let(:scoped_documents) { [] }

      it { expect(subject.completed?).to be(false) }
    end
  end
end
