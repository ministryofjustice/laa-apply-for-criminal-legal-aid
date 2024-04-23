require 'rails_helper'

RSpec.describe Tasks::Review do
  subject { described_class.new(crime_application:) }

  let(:crime_application) do
    CrimeApplication.new(
      legal_rep_first_name:,
      legal_rep_last_name:,
      legal_rep_telephone:,
    )
  end

  let(:legal_rep_first_name) { nil }
  let(:legal_rep_last_name) { nil }
  let(:legal_rep_telephone) { nil }

  before do
    allow(crime_application).to receive(:id).and_return('12345')
  end

  describe '#path' do
    it { expect(subject.path).to eq('/applications/12345/steps/submission/review') }
  end

  describe '#not_applicable?' do
    it { expect(subject.not_applicable?).to be(false) }
  end

  describe '#can_start?' do
    context 'when an initial application' do
      before do
        allow(
          subject
        ).to receive(:fulfilled?).with(Tasks::CaseDetails).and_return(case_details_fulfilled)

        allow(crime_application).to receive(:valid?).with(:submission) { valid_for_submission }
      end

      context 'when the Case details have been completed' do
        let(:case_details_fulfilled) { true }

        context 'and the application is valid for submsission' do
          let(:valid_for_submission) { true }

          it { expect(subject.can_start?).to be(true) }
        end

        context 'and the application is not valid for submsission' do
          let(:valid_for_submission) { false }

          it { expect(subject.can_start?).to be(false) }
        end
      end

      context 'when the Case details have not been completed' do
        let(:case_details_fulfilled) { false }

        it { expect(subject.can_start?).to be(false) }
      end
    end

    context 'when the application is PSE' do
      before do
        allow(subject).to receive(:fulfilled?).with(Tasks::EvidenceUpload).and_return(
          evidence_fulfilled
        )
        allow(crime_application).to receive(:pse?).and_return(true)
      end

      context 'when the evidence task has been completed' do
        let(:evidence_fulfilled) { true }

        it { expect(subject.can_start?).to be(true) }
      end

      context 'when the evidence task has not been completed yet' do
        let(:evidence_fulfilled) { false }

        it { expect(subject.can_start?).to be(false) }
      end
    end
  end

  describe '#in_progress?' do
    it { expect(subject.in_progress?).to be(true) }
  end

  describe '#completed?' do
    context 'when the Declaration task has some value' do
      let(:legal_rep_first_name) { 'John' }

      it { expect(subject.completed?).to be(true) }
    end

    context 'when the Declaration task has no values yet' do
      it { expect(subject.completed?).to be(false) }
    end
  end
end
