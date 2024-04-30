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
    allow(task).to receive(:fulfilled?).with(Tasks::ClientDetails) { client_details_fulfilled }
    allow(task).to receive(:requires_means_assessment?) { needs_means }
    allow(task).to receive(:fulfilled?).with(Tasks::IncomeAssessment) { income_fulfilled }
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

    context 'client details is not fulfilled' do
      let(:client_details_fulfilled) { false }

      it { is_expected.to be false }
    end

    context 'means assessment details is not required' do
      let(:client_details_fulfilled) { true }
      let(:needs_means) { false }

      it { is_expected.to be true }
    end

    context 'income is not fulfilled' do
      let(:client_details_fulfilled) { true }
      let(:needs_means) { true }
      let(:income_fulfilled) { false }

      it { is_expected.to be false }
    end

    context 'income is fulfilled' do
      let(:income_fulfilled) { true }
      let(:needs_means) { true }
      let(:client_details_fulfilled) { true }

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

    context 'case details are not fulfilled' do
      let(:income_fulfilled) { false }

      it { is_expected.to be false }
    end

    context 'case details are fulfilled' do
      let(:income_fulfilled) { true }

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
    subject(:completed) { task.completed? }

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
