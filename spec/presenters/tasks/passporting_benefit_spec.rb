require 'rails_helper'

RSpec.describe Tasks::PassportingBenefit do
  subject { described_class.new(crime_application:) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      to_param: '12345',
      applicant: applicant,
      kase: kase,
      appeal_no_changes?: false
    )
  end

  let(:applicant) { double under18?: false }
  let(:kase) { nil }

  let(:client_details_fulfilled) { true }

  before do
    allow(
      subject
    ).to receive(:fulfilled?).with(Tasks::ClientDetails).and_return(client_details_fulfilled)
  end

  describe '#path' do
    it { expect(subject.path).to eq('/applications/12345/steps/dwp/benefit_type') }
  end

  describe '#not_applicable?' do
    it { expect(subject.not_applicable?).to be(false) }

    context 'when applicant is under 18' do
      before do
        allow(applicant).to receive(:under18?).and_return(true)
      end

      it { expect(subject.not_applicable?).to be(true) }
    end

    context 'when case type is appeal no changes' do
      before do
        allow(crime_application).to receive(:appeal_no_changes?).and_return true
      end

      it { expect(subject.not_applicable?).to be(true) }
    end
  end

  describe '#can_start?, #in_progress?' do
    context 'when the client details task has been completed' do
      it { expect(subject.can_start?).to be(true) }
      it { expect(subject.in_progress?).to be(true) }
    end

    context 'when the client details task has not been completed yet' do
      let(:client_details_fulfilled) { false }

      it { expect(subject.can_start?).to be(false) }
      it { expect(subject.in_progress?).to be(false) }
    end
  end

  describe '#completed?' do
    it 'returns true when passporting benefit complete' do
      allow(crime_application).to receive(:valid?).with(:passporting_benefit).and_return(true)

      expect(subject.completed?).to be(true)
    end

    it 'returns false when passporting benefit is not complete' do
      allow(crime_application).to receive(:valid?).with(:passporting_benefit).and_return(false)

      expect(subject.completed?).to be(false)
    end
  end
end
