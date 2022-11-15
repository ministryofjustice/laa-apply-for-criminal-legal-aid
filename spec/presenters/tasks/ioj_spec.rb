require 'rails_helper'

RSpec.describe Tasks::Ioj do
  subject { described_class.new(crime_application:) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      to_param: '12345',
      case: kase
    )
  end

  let(:kase) { instance_double(Case, ioj:, ioj_passport:) }
  let(:ioj) { instance_double(Ioj, types: ioj_types) }
  let(:ioj_types) { [] }
  let(:ioj_passport) { [] }

  # We assume the completeness of the case details here, as
  # their statuses are tested in its own spec, no need to repeat
  let(:case_details_fulfilled) { true }

  before do
    allow(
      subject
    ).to receive(:fulfilled?).with(Tasks::CaseDetails).and_return(case_details_fulfilled)
    allow(kase).to receive(:ioj_passport).and_return(ioj_passport)
  end

  describe '#path' do
    it { expect(subject.path).to eq('/applications/12345/steps/case/ioj') }
  end

  describe '#not_applicable?' do
    it { expect(subject.not_applicable?).to be(false) }
  end

  describe '#can_start?' do
    context 'when the case details task has been completed' do
      it { expect(subject.can_start?).to be(true) }
    end

    context 'when the case details task has not been completed yet' do
      let(:case_details_fulfilled) { false }

      it { expect(subject.can_start?).to be(false) }
    end
  end

  describe '#in_progress?' do
    context 'when we have an Ioj passport record' do
      let(:ioj_passport) { ['foobar'] }

      it { expect(subject.in_progress?).to be(true) }
    end

    context 'when we do not have an Ioj passport record' do
      context 'and we have an Ioj record' do
        it { expect(subject.in_progress?).to be(true) }
      end

      context 'and we do not yet have an Ioj record' do
        let(:ioj) { nil }

        it { expect(subject.in_progress?).to be(false) }
      end
    end
  end

  describe '#completed?' do
    context 'when we have set an Ioj passport' do
      let(:ioj_passport) { ['foo'] }

      it { expect(subject.completed?).to be(true) }
    end

    context 'when we have not set an Ioj passport' do
      context 'and we have completed the Ioj details' do
        let(:ioj_types) { ['bar'] }

        it { expect(subject.completed?).to be(true) }
      end

      context 'and we have not yet completed the Ioj details' do
        it { expect(subject.completed?).to be(false) }
      end
    end
  end
end
