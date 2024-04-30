require 'rails_helper'

describe Summary::Sections::Codefendants do
  subject { described_class.new(crime_application) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      in_progress?: true,
      kase: kase,
    )
  end

  let(:kase) do
    instance_double(
      Case,
      has_codefendants: 'yes',
      codefendants: records,
    )
  end

  let(:records) { [Codefendant.new] }

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
    let(:component) { instance_double(Summary::Components::Codefendant) }

    before do
      allow(Summary::Components::Codefendant).to receive(:with_collection) { component }
    end

    it 'returns the component with actions' do
      expect(subject.answers).to be component

      expect(Summary::Components::Codefendant).to have_received(:with_collection).with(
        records, show_actions: true, show_record_actions: false
      )
    end

    context 'not in progress' do
      before do
        allow(crime_application).to receive(:in_progress?).and_return(false)
      end

      it 'returns the component without actions' do
        expect(subject.answers).to be component

        expect(Summary::Components::Codefendant).to have_received(:with_collection).with(
          records, show_actions: false, show_record_actions: false
        )
      end
    end
  end
end
