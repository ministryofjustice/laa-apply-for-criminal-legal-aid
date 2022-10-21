require 'rails_helper'

RSpec.describe Tasks::ClientDetails do
  subject { described_class.new(crime_application:) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      to_param: '12345',
      applicant: applicant,
    )
  end

  let(:applicant) { nil }

  describe '#path' do
    it { expect(subject.path).to eq('/applications/12345/steps/client/details') }
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
    context 'when we have completed contact details' do
      let(:applicant) do
        Applicant.new(
          telephone_number: '123456789',
          correspondence_address_type: 'something'
        )
      end

      it { expect(subject.completed?).to be(true) }
    end

    context 'when we have not completed yet contact details' do
      let(:applicant) do
        Applicant.new(
          telephone_number: '123456789',
          correspondence_address_type: ''
        )
      end

      it { expect(subject.completed?).to be(false) }
    end
  end
end
