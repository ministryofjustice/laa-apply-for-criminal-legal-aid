require 'rails_helper'

RSpec.describe Tasks::Declaration do
  subject { described_class.new(crime_application:) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      to_param: '12345',
      declaration_signed: declaration_signed,
    )
  end

  let(:declaration_signed) { nil }

  describe '#path' do
    it { expect(subject.path).to eq('/applications/12345/steps/submission/declaration') }
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
    context 'when we have signed the declaration' do
      let(:declaration_signed) { true }

      it { expect(subject.completed?).to be(true) }
    end

    context 'when we have not signed yet the declaration' do
      it { expect(subject.completed?).to be(false) }
    end
  end
end
