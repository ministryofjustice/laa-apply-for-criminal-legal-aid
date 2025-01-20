require 'rails_helper'

RSpec.describe Tasks::CapitalAssessment do
  subject(:task) { described_class.new(crime_application:) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      to_param: '12345',
      applicant: applicant,
      capital: capital
    )
  end

  let(:validator) do
    instance_double(
      CapitalAssessment::AnswersValidator,
      complete?: complete?, applicable?: applicable?
    )
  end

  let(:applicable?) { false }
  let(:complete?) { false }
  let(:applicant) { nil }
  let(:capital) { nil }

  before do
    allow(CapitalAssessment::AnswersValidator).to receive(:new)
      .with(record: capital, crime_application: crime_application).and_return(validator)
  end

  describe '#path' do
    subject(:path) { task.path }

    before { allow(task).to receive(:requires_full_capital?) { needs_full_capital } }

    context 'full capital is required' do
      let(:needs_full_capital) { true }

      it { is_expected.to eq '/applications/12345/steps/capital/which-assets-owned' }
    end

    context 'full capital is not required' do
      let(:needs_full_capital) { false }

      it { is_expected.to eq '/applications/12345/steps/capital/client-benefit-from-trust-fund' }
    end
  end

  describe '#not_applicable?' do
    subject(:not_applicable?) { task.not_applicable? }

    context 'when validator applicable' do
      let(:applicable?) { true }

      context 'when applicant nil' do
        let(:applicant) { nil }

        it { is_expected.to be false }
      end

      context 'when applicant present' do
        let(:applicant) { instance_double(Applicant) }

        it { is_expected.to be false }
      end
    end

    context 'when validator not applicable' do
      let(:applicable?) { false }

      context 'when applicant present' do
        let(:applicant) { instance_double(Applicant) }

        it { is_expected.to be true }
      end

      context 'when applicant nil' do
        let(:applicant) { nil }

        it { is_expected.to be false }
      end
    end
  end

  describe '#can_start?' do
    subject(:can_start) { task.can_start? }

    before do
      allow(task).to receive(:fulfilled?).with(Tasks::IncomeAssessment).and_return(
        income_fulfilled
      )
    end

    context 'when income is not fulfilled' do
      let(:income_fulfilled) { false }

      it { is_expected.to be false }
    end

    context 'when income is fulfilled' do
      let(:income_fulfilled) { true }

      it { is_expected.to be true }
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
    subject(:completed?) { task.completed? }

    context 'when answers and confirmation are complete' do
      let(:capital) { instance_double(Capital, complete?: true) }
      let(:complete?) { true }

      it { is_expected.to be true }
    end

    context 'when answers are complete but confirmation is not' do
      let(:capital) { instance_double(Capital, complete?: false) }
      let(:complete?) { true }

      it { is_expected.to be false }
    end

    context 'answers are incomplete' do
      let(:complete?) { false }

      it { is_expected.to be false }
    end
  end
end
