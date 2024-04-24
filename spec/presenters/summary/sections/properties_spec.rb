require 'rails_helper'

describe Summary::Sections::Properties do
  subject { described_class.new(crime_application) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      properties: records,
      in_progress?: true,
      capital: double(Capital, has_no_properties:),
      to_param: 12_345
    )
  end

  let(:records) { [Property.new] }
  let(:has_no_properties) { nil }

  describe '#list?' do
    it { expect(subject.list?).to be true }
  end

  describe '#show?' do
    context 'when there are properties' do
      it 'shows this section' do
        expect(subject.show?).to be true
      end
    end

    context 'when there are no properties' do
      let(:records) { [] }

      context 'when the full capital journey was shown' do
        let(:has_no_properties) { 'yes' }

        it 'shows this section' do
          expect(subject.show?).to be true
        end
      end

      context 'when the full capital journey was not shown' do
        it 'does not show this section' do
          expect(subject.show?).to be false
        end
      end
    end
  end

  describe '#answers' do
    context 'when there are properties' do
      let(:component) { instance_double(Summary::Components::GroupedList) }

      before do
        allow(Summary::Components::GroupedList).to receive(:new) { component }
      end

      it 'returns the grouped list component with actions' do
        expect(subject.answers).to be component

        expect(Summary::Components::GroupedList).to have_received(:new).with(
          items: records,
          group_by: :property_type,
          item_component: Summary::Components::Property,
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
            group_by: :property_type,
            item_component: Summary::Components::Property,
            show_actions: false,
            show_record_actions: false
          )
        end
      end
    end

    context 'when there are no properties' do
      let(:records) { [] }
      let(:answers) { subject.answers }
      let(:has_no_properties) { 'yes' }

      context 'when full capital journey was required' do
        it 'has the correct rows' do
          expect(answers.count).to eq(1)

          expect(answers[0]).to be_an_instance_of(Summary::Components::ValueAnswer)
          expect(answers[0].question).to eq(:has_assets)
          expect(answers[0].change_path).to match('applications/12345/steps/capital/which_assets_owned')
          expect(answers[0].value).to eq('none')
        end
      end
    end
  end
end
