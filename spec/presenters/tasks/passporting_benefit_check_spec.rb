require 'rails_helper'

RSpec.describe Tasks::PassportingBenefitCheck do
  subject(:task) { described_class.new(crime_application:) }

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
    allow(task).to receive(:fulfilled?).with(Tasks::ClientDetails).and_return(client_details_fulfilled)
  end

  describe '#path' do
    it { expect(task.path).to eq('/applications/12345/steps/dwp/benefit_type') }
  end

  describe '#not_applicable?' do
    subject(:not_applicable?) { task.not_applicable? }

    it { is_expected.to be(false) }

    context 'when applicant is under 18' do
      before do
        allow(applicant).to receive(:under18?).and_return(true)
      end

      it { is_expected.to be(true) }
    end

    context 'when case type is appeal no changes' do
      before do
        allow(crime_application).to receive(:appeal_no_changes?).and_return true
      end

      it { is_expected.to be(true) }
    end
  end

  describe '#can_start?, #in_progress?' do
    context 'when the client details task has been completed' do
      it { expect(task.can_start?).to be(true) }
      it { expect(task.in_progress?).to be(true) }
    end

    context 'when the client details task has not been completed yet' do
      let(:client_details_fulfilled) { false }

      it { expect(task.can_start?).to be(false) }
      it { expect(task.in_progress?).to be(false) }
    end
  end

  describe '#completed?' do
    subject(:completed?) { task.completed? }

    before do
      allow(PassportingBenefitCheck::AnswersValidator).to receive(:new).with(crime_application).and_return(
        instance_double(PassportingBenefitCheck::AnswersValidator, complete?: complete?)
      )
    end

    context 'answers are complete' do
      let(:complete?) { true }

      it { is_expected.to be true }
    end

    context 'answers are incomplete' do
      let(:complete?) { false }

      it { is_expected.to be false }
    end
  end
end
