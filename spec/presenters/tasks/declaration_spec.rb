require 'rails_helper'

RSpec.describe Tasks::Declaration do
  subject { described_class.new(crime_application:) }

  let(:crime_application) do
    CrimeApplication.new(
      legal_rep_first_name:,
    )
  end

  let(:legal_rep_first_name) { nil }

  before do
    allow(crime_application).to receive(:id).and_return('12345')
  end

  describe '#path' do
    it { expect(subject.path).to eq('/applications/12345/steps/submission/declaration') }
  end

  describe '#not_applicable?' do
    it { expect(subject.not_applicable?).to be(false) }
  end

  describe '#can_start?' do
    context 'when an initial application' do
      # We assume the completeness of the Ioj here, as
      # their statuses are tested in its own spec, no need to repeat
      before do
        allow(
          subject
        ).to receive(:fulfilled?).with(Tasks::Ioj).and_return(ioj_fulfilled)
      end

      context 'when the Ioj task has been completed' do
        let(:ioj_fulfilled) { true }

        it { expect(subject.can_start?).to be(true) }
      end

      context 'when the Ioj task has not been completed yet' do
        let(:ioj_fulfilled) { false }

        it { expect(subject.can_start?).to be(false) }
      end
    end

    context 'when a post submission evidence application' do
      before do
        crime_application.application_type = ApplicationType::POST_SUBMISSION_EVIDENCE

        allow(
          subject
        ).to receive(:fulfilled?).with(Tasks::EvidenceUpload).and_return(evidence_uploaded?)
      end

      context 'when supporting evidence has been uploaded' do
        let(:evidence_uploaded?) { true }

        it { expect(subject.can_start?).to be(true) }
      end

      context 'when supporting evidence has not been uploaded' do
        let(:evidence_uploaded?) { false }

        it { expect(subject.can_start?).to be(false) }
      end
    end
  end

  describe '#in_progress?' do
    context 'when the `legal_rep_first_name` is nil' do
      it { expect(subject.in_progress?).to be(false) }
    end

    context 'when the `legal_rep_first_name` is blank' do
      let(:legal_rep_first_name) { '' }

      it { expect(subject.in_progress?).to be(true) }
    end

    context 'when the `legal_rep_first_name` has some value' do
      let(:legal_rep_first_name) { 'John' }

      it { expect(subject.in_progress?).to be(true) }
    end
  end

  describe '#completed?' do
    it { expect(subject.completed?).to be(false) }
  end
end
