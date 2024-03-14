require 'rails_helper'

describe Summary::Sections::NationalSavingsCertificates do
  subject { described_class.new(crime_application) }

  let(:crime_application) {
    instance_double(CrimeApplication, national_savings_certificates: records, in_progress?: true)
  }
  let(:records) { [NationalSavingsCertificate.new] }

  describe '#list?' do
    it { expect(subject.list?).to be true }
  end

  describe '#show?' do
    context 'when there are certificates' do
      it 'shows this section' do
        expect(subject.show?).to be true
      end
    end

    context 'when there are no certificates' do
      let(:records) { [] }

      it 'does not show this section' do
        expect(subject.show?).to be false
      end
    end
  end

  describe '#answers' do
    let(:component) { instance_double(Summary::Components::NationalSavingsCertificate) }

    before do
      allow(Summary::Components::NationalSavingsCertificate).to receive(:with_collection) { component }
    end

    it 'returns the certificate component with actions' do
      expect(subject.answers).to be component

      expect(Summary::Components::NationalSavingsCertificate).to have_received(:with_collection).with(
        records, show_actions: true
      )
    end

    context 'not in progress' do
      before do
        allow(crime_application).to receive(:in_progress?).and_return(false)
      end

      it 'returns the certificate component without actions' do
        expect(subject.answers).to be component

        expect(Summary::Components::NationalSavingsCertificate).to have_received(:with_collection).with(
          records, show_actions: false
        )
      end
    end
  end
end
