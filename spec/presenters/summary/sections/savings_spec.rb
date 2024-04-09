require 'rails_helper'

describe Summary::Sections::Savings do
  subject { described_class.new(crime_application) }

  let(:crime_application) {
    instance_double(CrimeApplication, savings: records, in_progress?: true, capital: double, case: (double case_type:),
   to_param: 12_345)
  }
  let(:records) { [Saving.new] }
  let(:case_type) { 'either_way' }

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

      context 'when the full capital journey was shown' do
        it 'shows this section' do
          expect(subject.show?).to be true
        end
      end

      context 'when the full capital journey was not shown' do
        let(:case_type) { 'summary_only' }

        it 'does not show this section' do
          expect(subject.show?).to be false
        end
      end
    end
  end

  describe '#answers' do
    context 'when there are savings' do
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
            group_by: :saving_type,
            item_component: Summary::Components::Saving,
            show_actions: false,
            show_record_actions: false
          )
        end
      end
    end

    context 'when there are no savings' do
      let(:records) { [] }
      let(:answers) { subject.answers }

      context 'when full capital journey was required' do
        it 'has the correct rows' do
          expect(answers.count).to eq(1)

          expect(answers[0]).to be_an_instance_of(Summary::Components::ValueAnswer)
          expect(answers[0].question).to eq(:has_capital_savings)
          expect(answers[0].change_path).to match('applications/12345/steps/capital/which_savings_does_client_have')
          expect(answers[0].value).to eq('no')
        end
      end
    end
  end
end
