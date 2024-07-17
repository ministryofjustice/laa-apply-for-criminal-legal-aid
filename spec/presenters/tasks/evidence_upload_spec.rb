require 'rails_helper'

RSpec.describe Tasks::EvidenceUpload do
  subject { described_class.new(crime_application:) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      to_param: '12345',
      applicant: applicant,
      documents: documents
    )
  end

  let(:applicant) { instance_double Applicant }
  let(:documents) { [] }

  describe '#path' do
    it { expect(subject.path).to eq('/applications/12345/steps/evidence/upload') }
  end

  describe '#applicable?' do
    it { expect(subject.applicable?).to be(true) }
  end

  describe '#can_start?' do
    it { expect(subject.can_start?).to be(true) }

    context 'when applicant is not present' do
      let(:applicant) { nil }

      it { expect(subject.can_start?).to be(false) }
    end
  end

  describe '#in_progress?' do
    context 'when documents are not present' do
      it { expect(subject.in_progress?).to be(false) }
    end

    context 'when documents are present' do
      let(:documents) { ['doc'] }

      it { expect(subject.in_progress?).to be(true) }
    end
  end

  describe '#completed?' do
    it { expect(subject.completed?).to be(false) }
  end
end
