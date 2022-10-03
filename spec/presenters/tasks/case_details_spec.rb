require 'rails_helper'

RSpec.describe Tasks::CaseDetails do
  subject { described_class.new(crime_application:) }

  let(:crime_application) { instance_double(CrimeApplication, to_param: '12345') }

  describe '#path' do
    it { expect(subject.path).to eq('/applications/12345/steps/case/urn') }
  end

  describe '#not_applicable?' do
    it { expect(subject.not_applicable?).to be(false) }
  end

  describe '#can_start?' do
    before do
      allow(crime_application).to receive(:applicant).and_return(applicant)
    end

    context 'when we have a NINO' do
      let(:applicant) { double(nino: 'something') }

      it { expect(subject.can_start?).to be(true) }
    end

    context 'when we do not have a NINO' do
      let(:applicant) { double(nino: nil) }

      it { expect(subject.can_start?).to be(false) }
    end
  end

  describe '#in_progress?' do
    before do
      allow(crime_application).to receive(:case).and_return(kase)
    end

    context 'when we have a case record' do
      let(:kase) { double }

      it { expect(subject.in_progress?).to be(true) }
    end

    context 'when we do not have yet a case record' do
      let(:kase) { nil }

      it { expect(subject.in_progress?).to be(false) }
    end
  end

  describe '#completed?' do
    it { expect(subject.completed?).to be(false) }
  end
end
