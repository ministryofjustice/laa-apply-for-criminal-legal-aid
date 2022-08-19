require 'rails_helper'

RSpec.describe Tasks::CaseDetails do
  subject { described_class.new(crime_application: crime_application) }

  let(:crime_application) { instance_double(CrimeApplication) }

  describe '#path' do
    it { expect(subject.path).to eq('') }
  end

  describe '#not_applicable?' do
    it { expect(subject.not_applicable?).to eq(false) }
  end

  describe '#can_start?' do
    before do
      allow(crime_application).to receive(:applicant).and_return(applicant)
    end

    context 'when we have a NINO' do
      let(:applicant) { double(nino: 'something') }
      it { expect(subject.can_start?).to eq(true) }
    end

    context 'when we do not have a NINO' do
      let(:applicant) { double(nino: nil) }
      it { expect(subject.can_start?).to eq(false) }
    end
  end

  describe '#in_progress?' do
    it { expect(subject.in_progress?).to eq(false) }
  end

  describe '#completed?' do
    it { expect(subject.completed?).to eq(false) }
  end
end
