require 'rails_helper'

RSpec.describe Tasks::Review do
  subject { described_class.new(crime_application:) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      to_param: '12345',
    )
  end

  describe '#path' do
    it { expect(subject.path).to eq('/applications/12345/steps/submission/review') }
  end

  describe '#not_applicable?' do
    it { expect(subject.not_applicable?).to be(false) }
  end

  describe '#can_start?' do
    # We assume the completeness of the Ioj here, as
    # their statuses are tested in its own spec, no need to repeat
    before do
      allow(
        subject
      ).to receive(:fulfilled?).with(Tasks::Ioj).and_return(ioj_fulfilled)
    end

    context 'when the Ioj task has been completed' do
      let(:ioj_fulfilled) { true }

      it { expect(subject.can_start?).to be(true) }
    end

    context 'when the Ioj task has not been completed yet' do
      let(:ioj_fulfilled) { false }

      it { expect(subject.can_start?).to be(false) }
    end
  end

  describe '#in_progress?' do
    it { expect(subject.in_progress?).to be(true) }
  end

  describe '#completed?' do
    # We assume the completeness of the Declaration here, as
    # their statuses are tested in its own spec, no need to repeat
    before do
      allow(
        subject
      ).to receive(:fulfilled?).with(Tasks::Declaration).and_return(declaration_fulfilled)
    end

    context 'when the Declaration task has been completed' do
      let(:declaration_fulfilled) { true }

      it { expect(subject.completed?).to be(true) }
    end

    context 'when the Declaration task has not been completed yet' do
      let(:declaration_fulfilled) { false }

      it { expect(subject.completed?).to be(false) }
    end
  end
end
