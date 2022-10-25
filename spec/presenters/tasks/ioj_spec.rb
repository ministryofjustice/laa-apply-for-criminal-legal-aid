require 'rails_helper'

RSpec.describe Tasks::Ioj do
  subject { described_class.new(crime_application:) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      to_param: '12345',
      case: instance_double(Case, ioj:),
    )
  end

  let(:ioj) { instance_double(Ioj, types: ioj_types) }
  let(:ioj_types) { [] }

  # We assume the completeness of the case details here, as
  # their statuses are tested in its own spec, no need to repeat
  let(:case_details_fulfilled) { true }

  before do
    allow(
      subject
    ).to receive(:fulfilled?).with(Tasks::CaseDetails).and_return(case_details_fulfilled)
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
    context 'when we have an Ioj record' do
      it { expect(subject.in_progress?).to be(true) }
    end

    context 'when we do not have yet an Ioj record' do
      let(:ioj) { nil }

      it { expect(subject.in_progress?).to be(false) }
    end
  end

  describe '#completed?' do
    context 'when we have completed the Ioj details' do
      let(:ioj_types) { ['foobar'] }

      it { expect(subject.completed?).to be(true) }
    end

    context 'when we have not completed yet the Ioj details' do
      it { expect(subject.completed?).to be(false) }
    end
  end
end
