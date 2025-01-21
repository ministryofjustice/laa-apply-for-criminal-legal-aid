require 'rails_helper'

RSpec.describe Tasks::PartnerDetails do
  subject(:task) { described_class.new(crime_application:) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      to_param: '12345',
      partner_detail: partner_detail,
    )
  end

  let(:applicable?) { true }
  let(:complete?) { false }
  let(:partner_detail) { nil }

  let(:validator) do
    instance_double(
      PartnerDetails::AnswersValidator,
      complete?: complete?, applicable?: applicable?
    )
  end

  before do
    allow(PartnerDetails::AnswersValidator).to receive(:new)
      .with(record: partner_detail, crime_application: crime_application).and_return(validator)
  end

  describe '#path' do
    it { expect(subject.path).to eq('/applications/12345/steps/client/does-client-have-partner') }
  end

  describe '#not_applicable?' do
    it { expect(subject.not_applicable?).to be(false) }
  end

  describe '#can_start?' do
    before do
      allow(subject).to receive(:fulfilled?).with(Tasks::ClientDetails).and_return(true)
    end

    it { expect(subject.can_start?).to be(true) }
  end

  describe '#in_progress?' do
    context 'when we have a partner_detail record' do
      let(:partner_detail) { double }

      it { expect(subject.in_progress?).to be(true) }
    end

    context 'when we do not have yet a partner_detail record' do
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
