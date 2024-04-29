require 'rails_helper'

RSpec.describe Tasks::IncomeAssessment do
  subject(:task) { described_class.new(crime_application:) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      to_param: '12345',
      applicant: applicant,
      income: income,
      kase: kase,
    )
  end

  let(:applicant) { nil }
  let(:kase) { nil }
  let(:income) { nil }

  describe '#path' do
    it { expect(subject.path).to eq('/applications/12345/steps/income/what_is_clients_employment_status') }
  end

  describe '#not_applicable?' do
    subject(:not_applicable) { task.not_applicable? }

    before do
      allow(task).to receive(:fulfilled?).with(Tasks::ClientDetails) { fulfilled }
    end

    context 'client details are not fulfilled' do
      let(:fulfilled) { false }

      it { is_expected.to be false }
    end

    context 'client details are fulfilled' do
      let(:fulfilled) { true }

      context 'and means assessment required' do
        let(:needs_means) { true }

        before do
          allow(task).to receive(:requires_means_assessment?) { needs_means }
        end

        it { is_expected.to be false }
      end

      context 'and means assessment is not required' do
        let(:needs_means) { false }

        before do
          allow(task).to receive(:requires_means_assessment?) { needs_means }
        end

        it { is_expected.to be true }
      end
    end
  end

  describe '#can_start?' do
    subject(:can_start) { task.can_start? }

    before do
      allow(task).to receive(:fulfilled?).with(Tasks::CaseDetails) { fulfilled }
    end

    context 'case details are not fulfilled' do
      let(:fulfilled) { false }

      it { is_expected.to be false }
    end

    context 'case details are fulfilled' do
      let(:fulfilled) { true }

      context 'and means assessment required' do
        let(:needs_means) { true }

        before do
          allow(task).to receive(:requires_means_assessment?) { needs_means }
        end

        it { is_expected.to be true }
      end

      context 'and means assessment is not required' do
        let(:needs_means) { false }

        before do
          allow(task).to receive(:requires_means_assessment?) { needs_means }
        end

        it { is_expected.to be false }
      end
    end
  end

  describe '#in_progress?' do
    subject(:in_progress) { task.in_progress? }

    context 'there is no income' do
      it { is_expected.to be false }
    end

    context 'income is present' do
      let(:income) { instance_double(Income) }

      context 'and means assessment required' do
        it { is_expected.to be true }
      end
    end
  end

  describe '#completed?' do
    subject(:in_progress) { task.completed? }

    let(:income) { instance_double(Income) }

    context 'income is not completed' do
      before { allow(income).to receive(:complete?).and_return(false) }

      it { is_expected.to be false }
    end

    context 'income is completed' do
      before { allow(income).to receive(:complete?).and_return(true) }

      it { is_expected.to be true }
    end
  end
end
