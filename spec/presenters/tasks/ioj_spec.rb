require 'rails_helper'

RSpec.describe Tasks::Ioj do
  subject(:task) { described_class.new(crime_application:) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      to_param: '12345',
      ioj: ioj,
    )
  end

  let(:applicable?) { true }
  let(:complete?) { false }
  let(:ioj) { nil }
  let(:passporter_result) { false }

  let(:validator) do
    instance_double(
      InterestsOfJustice::AnswersValidator,
      complete?: complete?, applicable?: applicable?
    )
  end

  before do
    allow(InterestsOfJustice::AnswersValidator).to receive(:new)
      .with(crime_application).and_return(validator)

    allow(crime_application).to receive(:ioj_passported?).and_return(passporter_result)
  end

  describe '#path' do
    context 'when the application is Ioj passported (and there is no override)' do
      let(:passporter_result) { true }

      it { expect(subject.path).to eq('/applications/12345/steps/case/ioj-passport') }
    end

    context 'when the application is not Ioj passported (or there is override)' do
      it { expect(subject.path).to eq('/applications/12345/steps/case/ioj') }
    end
  end

  describe '#not_applicable?' do
    it { expect(subject.not_applicable?).to be(false) }
  end

  describe '#can_start?' do
    before do
      allow(subject).to receive(:fulfilled?).with(Tasks::CaseDetails).and_return(true)
    end

    it { expect(subject.can_start?).to be(true) }
  end

  describe '#in_progress?' do
    context 'when we have an ioj record' do
      let(:ioj) { double }

      it { expect(subject.in_progress?).to be(true) }
    end

    context 'when we do not have yet an ioj record' do
      it { expect(subject.in_progress?).to be(false) }

      context 'when ioj_passported' do
        let(:passporter_result) { true }

        it { expect(subject.in_progress?).to be(true) }
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
