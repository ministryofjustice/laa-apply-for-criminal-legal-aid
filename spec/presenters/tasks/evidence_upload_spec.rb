require 'rails_helper'

RSpec.describe Tasks::EvidenceUpload do
  subject { described_class.new(crime_application:) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      to_param: '12345',
      documents: documents,
    )
  end

  let(:documents) { [] }

  describe '#path' do
    it { expect(subject.path).to eq('/applications/12345/steps/evidence/upload') }
  end

  describe '#not_applicable?' do
    it { expect(subject.not_applicable?).to be(false) }
  end

  describe '#can_start?' do
    it { expect(subject.can_start?).to be(true) }
  end

  describe '#in_progress?' do
    context 'when there are any documents' do
      let(:documents) { ['doc'] }

      it { expect(subject.in_progress?).to be(true) }
    end

    context 'when there are no documents yet' do
      let(:documents) { [] }

      it { expect(subject.in_progress?).to be(false) }
    end
  end

  describe '#completed?' do
    let(:documents) { double(stored: scoped_documents) }

    context 'when there are any stored documents' do
      let(:scoped_documents) { ['stored_doc'] }

      it { expect(subject.completed?).to be(true) }
    end

    context 'when there are no stored documents yet' do
      let(:scoped_documents) { [] }

      it { expect(subject.completed?).to be(false) }
    end
  end
end
