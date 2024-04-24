require 'rails_helper'

RSpec.describe Tasks::CapitalAssessment do
  subject(:task) { described_class.new(crime_application:) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      to_param: '12345',
      applicant: applicant,
      capital: capital,
      kase: kase,
    )
  end

  let(:applicant) { nil }
  let(:kase) { nil }
  let(:capital) { nil }

  before do
    allow(task).to receive(:fulfilled?).with(Tasks::IncomeAssessment) { income_fulfiled }
    allow(task).to receive(:requires_full_means_assessment?) { needs_full_means }
  end

  describe '#path' do
    subject(:path) { task.path }

    before { allow(task).to receive(:requires_full_capital?) { needs_full_capital } }

    context 'full capital is required' do
      let(:needs_full_capital) { true }

      it { is_expected.to eq '/applications/12345/steps/capital/which_assets_owned' }
    end

    context 'full capital is not required' do
      let(:needs_full_capital) { false }

      it { is_expected.to eq '/applications/12345/steps/capital/client_benefit_from_trust_fund' }
    end
  end

  describe '#not_applicable?' do
    subject(:not_applicable) { task.not_applicable? }

    context 'income is not fulfiled' do
      let(:income_fulfiled) { false }

      it { is_expected.to be false }
    end

    context 'income is fulfiled' do
      let(:income_fulfiled) { true }

      context 'and full means assessment required' do
        let(:needs_full_means) { true }

        it { is_expected.to be false }
      end

      context 'and means assessment is not required' do
        let(:needs_full_means) { false }

        it { is_expected.to be true }
      end
    end
  end

  describe '#can_start?' do
    subject(:can_start) { task.can_start? }

    context 'case details are not fulfiled' do
      let(:income_fulfiled) { false }

      it { is_expected.to be false }
    end

    context 'case details are fulfiled' do
      let(:income_fulfiled) { true }

      context 'and means assessment required' do
        let(:needs_full_means) { true }

        before do
          allow(task).to receive(:requires_means_assessment?) { needs_means }
        end

        it { is_expected.to be true }
      end

      context 'and means assessment is not required' do
        let(:needs_full_means) { false }

        it { is_expected.to be false }
      end
    end
  end

  describe '#in_progress?' do
    subject(:in_progress) { task.in_progress? }

    context 'there is no capital' do
      it { is_expected.to be false }
    end

    context 'capital is present' do
      let(:capital) { instance_double(Capital) }

      context 'and means assessment required' do
        it { is_expected.to be true }
      end
    end
  end

  describe '#completed?' do
    subject(:in_progress) { task.completed? }

    let(:capital) { instance_double(Capital) }

    context 'capital is not completed' do
      before { allow(capital).to receive(:complete?).and_return(false) }

      it { is_expected.to be false }
    end

    context 'capital is completed' do
      before { allow(capital).to receive(:complete?).and_return(true) }

      it { is_expected.to be true }
    end
  end
end
