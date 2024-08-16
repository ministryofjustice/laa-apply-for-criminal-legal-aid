require 'rails_helper'

RSpec.describe Tasks::Ioj do
  subject { described_class.new(crime_application:) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      to_param: '12345',
      ioj_passport: ioj_passport,
      ioj: ioj,
      cifc?: cifc?
    )
  end

  let(:ioj) {
    instance_double(Ioj, types: ioj_types, loss_of_liberty_justification: loss_of_liberty_justification)
  }
  let(:ioj_types) { [] }
  let(:ioj_passport) { [] }
  let(:cifc?) { false }
  let(:loss_of_liberty_justification) { 'loss_of_liberty justification' }

  # We assume the completeness of the case details here, as
  # their statuses are tested in its own spec, no need to repeat
  let(:case_details_fulfilled) { true }

  before do
    RSpec::Mocks.configuration.allow_message_expectations_on_nil = true
    allow(
      subject
    ).to receive(:fulfilled?).with(Tasks::CaseDetails).and_return(case_details_fulfilled)

    allow(ioj).to receive(:values_at).with('loss_of_liberty_justification').and_return([loss_of_liberty_justification])
  end

  after do
    RSpec::Mocks.configuration.allow_message_expectations_on_nil = false
  end

  describe '#path' do
    before do
      allow(crime_application).to receive(:ioj_passported?).and_return(passporter_result)
    end

    context 'when the application is Ioj passported (and there is no override)' do
      let(:passporter_result) { true }

      it { expect(subject.path).to eq('/applications/12345/steps/case/ioj_passport') }
    end

    context 'when the application is not Ioj passported (or there is override)' do
      let(:passporter_result) { false }

      it { expect(subject.path).to eq('/applications/12345/steps/case/ioj') }
    end
  end

  describe '#not_applicable?' do
    it { expect(subject.not_applicable?).to be(false) }

    context 'with change in financial circumstances application' do
      let(:cifc?) { true }

      before do
        allow(FeatureFlags).to receive(:cifc_journey) {
          instance_double(FeatureFlags::EnabledFeature, enabled?: true)
        }
      end

      it { expect(subject.not_applicable?).to be(true) }
    end
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
    before do
      allow(crime_application).to receive(:ioj_passported?).and_return(passporter_result)
    end

    context 'when the application is Ioj passported (and there is no override)' do
      let(:passporter_result) { true }

      it { expect(subject.completed?).to be(true) }
    end

    context 'when the application is not Ioj passported (or there is override)' do
      let(:passporter_result) { false }

      context 'and there is no Ioj record yet' do
        let(:ioj) { nil }

        it { expect(subject.completed?).to be(false) }
      end

      context 'and we have completed the Ioj details' do
        let(:ioj_types) { ['loss_of_liberty'] }

        it { expect(subject.completed?).to be(true) }
      end

      context 'and we have not yet completed the Ioj details' do
        it { expect(subject.completed?).to be(false) }

        context 'when types are selected but relevant justification is missing' do
          let(:ioj_types) { ['loss_of_liberty'] }
          let(:loss_of_liberty_justification) { nil }

          it { expect(subject.completed?).to be(false) }
        end
      end
    end
  end
end
