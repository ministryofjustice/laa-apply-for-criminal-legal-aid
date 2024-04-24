require 'rails_helper'

RSpec.describe Tasks::OutgoingsAssessment do
  subject(:task) { described_class.new(crime_application:) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      to_param: '12345',
      applicant: applicant,
      outgoings: outgoings,
      kase: kase,
    )
  end

  let(:applicant) { nil }
  let(:kase) { nil }
  let(:outgoings) { nil }

  before do
    allow(task).to receive(:fulfilled?).with(Tasks::IncomeAssessment) { income_fulfiled }
    allow(task).to receive(:requires_full_means_assessment?) { needs_full_means }
  end

  describe '#path' do
    it { expect(subject.path).to eq('/applications/12345/steps/outgoings/housing_payments_where_lives') }
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

    context 'there is no outgoings' do
      it { is_expected.to be false }
    end

    context 'outgoings is present' do
      let(:outgoings) { instance_double(Outgoings) }

      context 'and means assessment required' do
        it { is_expected.to be true }
      end
    end
  end

  describe '#completed?' do
    subject(:in_progress) { task.completed? }

    let(:outgoings) { instance_double(Outgoings) }

    context 'outgoings is not completed' do
      before { allow(outgoings).to receive(:complete?).and_return(false) }

      it { is_expected.to be false }
    end

    context 'outgoings is completed' do
      before { allow(outgoings).to receive(:complete?).and_return(true) }

      it { is_expected.to be true }
    end
  end
end
