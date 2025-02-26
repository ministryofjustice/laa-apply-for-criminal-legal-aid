require 'rails_helper'

RSpec.describe Tasks::CaseDetails do
  subject(:task) { described_class.new(crime_application:) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      to_param: '12345',
      age_passported?: age_passported?,
      kase: kase,
      appeal_no_changes?: appeal_no_changes,
      non_means_tested?: false
    )
  end

  let(:kase) { nil }

  let(:client_details_fulfilled) { true }
  let(:passporting_benefit_fulfilled) { true }
  let(:appeal_no_changes) { false }
  let(:age_passported?) { false }

  before do
    allow(
      task
    ).to receive(:fulfilled?).with(Tasks::ClientDetails).and_return(client_details_fulfilled)
    allow(
      task
    ).to receive(:fulfilled?).with(Tasks::PassportingBenefitCheck).and_return(passporting_benefit_fulfilled)
  end

  describe '#path' do
    it { expect(task.path).to eq('/applications/12345/steps/case/urn') }
  end

  describe '#not_applicable?' do
    it { expect(task.not_applicable?).to be(false) }
  end

  describe '#can_start?' do
    context 'when the case type is appeal no changes' do
      let(:appeal_no_changes) { true }

      context 'when the client details task has been completed' do
        it { expect(task.can_start?).to be(true) }
      end

      context 'when the client details task has not been completed yet' do
        let(:client_details_fulfilled) { false }

        it { expect(task.can_start?).to be(false) }
      end
    end

    context 'when passported on age' do
      let(:age_passported?) { true }

      context 'when the client details task has been completed' do
        it { expect(task.can_start?).to be(true) }
      end

      context 'when the client details task has not been completed yet' do
        let(:client_details_fulfilled) { false }

        it { expect(task.can_start?).to be(false) }
      end
    end

    context 'when the passporting benefit task has been completed' do
      it { expect(task.can_start?).to be(true) }
    end

    context 'when the passporting benefit task has not been completed yet' do
      let(:passporting_benefit_fulfilled) { false }

      it { expect(task.can_start?).to be(false) }
    end
  end

  describe '#in_progress?' do
    context 'when we have a case record' do
      let(:kase) { instance_double(Case) }

      it { expect(task.in_progress?).to be(true) }
    end

    context 'when we do not have yet a case record' do
      it { expect(task.in_progress?).to be(false) }
    end
  end

  describe '#completed?' do
    subject(:completed) { task.completed? }

    let(:kase) { instance_double(Case) }

    context 'kase is not completed' do
      before { allow(kase).to receive(:complete?).and_return(false) }

      it { is_expected.to be false }
    end

    context 'kase is completed' do
      before { allow(kase).to receive(:complete?).and_return(true) }

      it { is_expected.to be true }
    end
  end
end
