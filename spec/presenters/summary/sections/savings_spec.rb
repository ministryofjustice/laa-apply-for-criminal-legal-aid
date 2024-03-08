require 'rails_helper'

describe Summary::Sections::Savings do
  subject { described_class.new(crime_application) }

  let(:crime_application) { instance_double(CrimeApplication, savings: records, in_progress?: true) }
  let(:records) { [Saving.new] }

  describe '#list?' do
    it { expect(subject.list?).to be true }
  end

  describe '#show?' do
    context 'when there are savings' do
      it 'shows this section' do
        expect(subject.show?).to be true
      end
    end

    context 'when there are no savings' do
      let(:records) { [] }

      it 'does not show this section' do
        expect(subject.show?).to be false
      end
    end
  end

  describe '#answers' do
    let(:component) { instance_double(Summary::Components::GroupedList) }

    before do
      allow(Summary::Components::GroupedList).to receive(:new) { component }
    end

    it 'returns the grouped list component with actions' do
      expect(subject.answers).to be component

      expect(Summary::Components::GroupedList).to have_received(:new).with(
        items: records,
        group_by: :saving_type,
        item_component: Summary::Components::Saving,
        show_actions: true
      )
    end

    context 'not in progress' do
      before do
        allow(crime_application).to receive(:in_progress?).and_return(false)
      end

      it 'returns the grouped list component without actions' do
        expect(subject.answers).to be component

        expect(Summary::Components::GroupedList).to have_received(:new).with(
          items: records,
          group_by: :saving_type,
          item_component: Summary::Components::Saving,
          show_actions: false
        )
      end
    end
  end
end
