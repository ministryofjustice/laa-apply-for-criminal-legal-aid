require 'rails_helper'

describe Summary::Sections::Offences do
  subject { described_class.new(crime_application) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      kase: kase,
      in_progress?: true
    )
  end

  let(:kase) do
    instance_double(
      Case,
      charges: records,
    )
  end

  let(:records) { [instance_double(Charge)] }

  describe '#list?' do
    it { expect(subject.list?).to be true }
  end

  describe '#show?' do
    context 'when there is a case' do
      it 'shows this section' do
        expect(subject.show?).to be(true)
      end
    end

    context 'when there is no case' do
      let(:kase) { nil }

      it 'does not show this section' do
        expect(subject.show?).to be(false)
      end
    end
  end

  describe '#answers' do
    let(:component) { instance_double(Summary::Components::Offence) }

    before do
      allow(Summary::Components::Offence).to receive(:with_collection) { component }
    end

    it 'returns the component with actions' do
      expect(subject.answers).to be component

      expect(Summary::Components::Offence).to have_received(:with_collection).with(
        records, show_actions: true, show_record_actions: false
      )
    end

    context 'not in progress' do
      before do
        allow(crime_application).to receive(:in_progress?).and_return(false)
      end

      it 'returns the component without actions' do
        expect(subject.answers).to be component

        expect(Summary::Components::Offence).to have_received(:with_collection).with(
          records, show_actions: false, show_record_actions: false
        )
      end
    end
  end
end
