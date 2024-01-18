require 'rails_helper'

RSpec.describe Tasks::AdditionalInformation do
  subject { described_class.new(crime_application:) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      to_param: '12345'
    )
  end

  let(:pse?) { true }

  before do
    allow(crime_application).to receive(:pse?).and_return(pse?)
  end

  describe '#path' do
    it { expect(subject.path).to eq('/applications/12345/steps/evidence/additional_information') }
  end

  describe '#not_applicable?' do
    context 'when post submission evidence' do
      it { expect(subject.not_applicable?).to be(false) }
    end

    context 'when an initial application' do
      let(:pse?) { false }

      it { expect(subject.not_applicable?).to be(true) }
    end
  end

  describe '#can_start?' do
    before do
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

  describe '#in_progress?' do
    before do
      allow(
        crime_application
      ).to receive(:additional_information).and_return additional_information
    end

    context 'when additional information is given' do
      let(:additional_information) { 'Some info' }

      it { expect(subject.in_progress?).to be(true) }
    end

    context 'when additional information has not yet been given' do
      let(:additional_information) { nil }

      it { expect(subject.in_progress?).to be(false) }
    end
  end

  describe '#completed?' do
    before do
      allow(
        crime_application
      ).to receive(:additional_information).and_return additional_information
    end

    context 'when additional information is given' do
      let(:additional_information) { 'Some info' }

      it { expect(subject.completed?).to be(true) }
    end

    context 'when additional information has not yet been given' do
      let(:additional_information) { nil }

      it { expect(subject.completed?).to be(false) }
    end
  end
end
