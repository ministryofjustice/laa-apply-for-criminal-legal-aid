require 'rails_helper'

RSpec.describe Tasks::ClientDetails do
  subject(:task) { described_class.new(crime_application:) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      to_param: '12345',
      applicant: applicant,
    )
  end
  let(:applicable?) { true }
  let(:complete?) { false }
  let(:applicant) { nil }

  let(:validator) do
    instance_double(
      ClientDetails::AnswersValidator,
      complete?: complete?, applicable?: applicable?
    )
  end

  before do
    allow(ClientDetails::AnswersValidator).to receive(:new)
      .with(record: crime_application, crime_application: crime_application).and_return(validator)
  end

  describe '#path' do
    before do
      allow(FeatureFlags).to receive(:passported_partner_journey) {
        instance_double(FeatureFlags::EnabledFeature, enabled?: passported_partner_journey_enabled)
      }
    end

    context 'when passported partner journey is enabled' do
      let(:passported_partner_journey_enabled) { true }

      it { expect(subject.path).to eq('/applications/12345/steps/client/is_application_means_tested') }
    end

    context 'when passported partner journey not is enabled' do
      let(:passported_partner_journey_enabled) { false }

      it { expect(subject.path).to eq('/applications/12345/steps/client/details') }
    end
  end

  describe '#not_applicable?' do
    it { expect(subject.not_applicable?).to be(false) }
  end

  describe '#can_start?' do
    it { expect(subject.can_start?).to be(true) }
  end

  describe '#in_progress?' do
    context 'when we have an applicant record' do
      let(:applicant) { double }

      it { expect(subject.in_progress?).to be(true) }
    end

    context 'when we do not have yet an applicant record' do
      it { expect(subject.in_progress?).to be(false) }
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
