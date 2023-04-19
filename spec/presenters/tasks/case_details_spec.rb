require 'rails_helper'

RSpec.describe Tasks::CaseDetails do
  subject { described_class.new(crime_application:) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      to_param: '12345',
      applicant: applicant,
      case: kase,
    )
  end

  let(:applicant) { nil }
  let(:kase) { nil }

  describe '#path' do
    it { expect(subject.path).to eq('/applications/12345/steps/case/urn') }
  end

  describe '#not_applicable?' do
    it { expect(subject.not_applicable?).to be(false) }
  end

  describe '#can_start?' do
    context 'when there is no applicant record yet' do
      it { expect(subject.can_start?).to be(false) }
    end

    context 'when there is an applicant record' do
      let(:applicant) { double }

      before do
        allow(crime_application).to receive(:means_passported?).and_return(means_passported)
      end

      context 'when applicant is means passported' do
        let(:means_passported) { true }

        it { expect(subject.can_start?).to be(true) }
      end

      context 'when applicant is not means passported' do
        let(:means_passported) { false }

        it { expect(subject.can_start?).to be(false) }
      end
    end
  end

  describe '#in_progress?' do
    context 'when we have a case record' do
      let(:kase) { double }

      it { expect(subject.in_progress?).to be(true) }
    end

    context 'when we do not have yet a case record' do
      it { expect(subject.in_progress?).to be(false) }
    end
  end

  describe '#completed?' do
    context 'when we have completed court hearing details' do
      let(:kase) do
        Case.new(
          hearing_court_name: 'Court name',
          hearing_date: Date.tomorrow,
        )
      end

      it { expect(subject.completed?).to be(true) }
    end

    context 'when we have not completed yet court hearing details' do
      let(:kase) do
        Case.new(
          hearing_court_name: 'Court name',
          hearing_date: nil,
        )
      end

      it { expect(subject.completed?).to be(false) }
    end
  end
end
