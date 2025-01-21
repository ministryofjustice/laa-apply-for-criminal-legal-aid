require 'rails_helper'

RSpec.describe Tasks::OutgoingsAssessment do
  subject(:task) { described_class.new(crime_application:) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      to_param: '12345',
      applicant: applicant,
      outgoings: outgoings,
    )
  end

  let(:applicant) { nil }
  let(:outgoings) { nil }

  let(:validator) do
    instance_double(
      OutgoingsAssessment::AnswersValidator,
      complete?: complete?, applicable?: applicable?
    )
  end

  let(:applicable?) { false }
  let(:complete?) { false }

  before do
    allow(OutgoingsAssessment::AnswersValidator).to receive(:new)
      .with(crime_application: crime_application, record: nil).and_return(validator)
  end

  describe '#path' do
    it { expect(subject.path).to eq('/applications/12345/steps/outgoings/housing-payments-where-lives') }
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
    subject(:completed?) { task.completed? }

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
