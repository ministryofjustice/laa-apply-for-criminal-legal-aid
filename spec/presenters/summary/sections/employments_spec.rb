require 'rails_helper'

describe Summary::Sections::Employments do
  subject { described_class.new(crime_application) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      employments: records,
      in_progress?: true,
      to_param: 12_345
    )
  end

  let(:records) { [Employment.new] }

  describe '#list?' do
    context 'when there are employments' do
      it { expect(subject.list?).to be true }
    end

    context 'when there are no employments' do
      let(:records) { [] }

      it { expect(subject.list?).to be false }
    end
  end

  describe '#answers' do
    context 'when there are employments' do
      let(:component) { instance_double(Summary::Components::GroupedList) }

      before do
        allow(Summary::Components::GroupedList).to receive(:new) { component }
      end

      it 'returns the grouped list component with actions' do
        expect(subject.answers).to be component

        expect(Summary::Components::GroupedList).to have_received(:new).with(
          items: records,
          group_by: :ownership_type,
          item_component: Summary::Components::Employment,
          show_actions: true,
          show_record_actions: false
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
            group_by: :ownership_type,
            item_component: Summary::Components::Employment,
            show_actions: false,
            show_record_actions: false
          )
        end
      end
    end

    context 'when there are no employments' do
      let(:records) { [] }
      let(:answers) { subject.answers }
      let(:has_no_employments) { 'yes' }

      context 'when full capital journey was required' do
        it 'has the correct rows' do
          expect(answers.count).to eq(0)
        end
      end
    end
  end
end
