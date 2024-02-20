require 'rails_helper'

RSpec.describe Tasks::MoreInformation do
  subject { described_class.new(crime_application:) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      to_param: '12345'
    )
  end

  describe '#path' do
    it { expect(subject.path).to eq('/applications/12345/steps/submission/more_information') }
  end

  describe '#can_start?' do
    before do
      allow(
        subject
      ).to receive(:fulfilled?).with(Tasks::EvidenceUpload).and_return(evidence_uploaded?)

      allow(
        subject
      ).to receive(:fulfilled?).with(Tasks::CaseDetails).and_return(case_details?)
    end

    context 'when supporting evidence has been uploaded' do
      let(:evidence_uploaded?) { true }
      let(:case_details?) { false }

      it { expect(subject.can_start?).to be(true) }
    end

    context 'when supporting evidence has not been uploaded and case details are not fulfilled' do
      let(:evidence_uploaded?) { false }
      let(:case_details?) { false }

      it { expect(subject.can_start?).to be(false) }
    end

    context 'when case details are fulfilled' do
      let(:evidence_uploaded?) { false }
      let(:case_details?) { true }

      it { expect(subject.can_start?).to be(true) }
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
