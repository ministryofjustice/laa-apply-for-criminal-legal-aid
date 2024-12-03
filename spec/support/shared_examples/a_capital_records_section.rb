RSpec.shared_examples 'a capital records section' do |_options|
  subject(:presenter) { described_class.new(crime_application) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      to_param: 12_345,
      capital: capital, in_progress?: true
    )
  end

  let(:records) { [record] }
  let(:expected_no_records_answer) { 'No' }
  let(:expected_no_records_answer_value) { YesNoAnswer::NO }

  describe '#list?' do
    subject(:list?) { presenter.list? }

    let(:has_no_answer) { nil }

    context 'when there are records' do
      it { is_expected.to be true }
    end

    context 'when there are no records' do
      let(:records) { [] }

      it { is_expected.to be false }
    end
  end

  describe '#show?' do
    subject(:show?) { presenter.show? }

    context 'when there are records' do
      let(:has_no_answer) { nil }
      let(:records) { [record] }

      it { is_expected.to be true }
    end

    context 'when there are no records' do
      let(:records) { [] }

      context 'when the has no question answer is yes' do
        let(:has_no_answer) { 'yes' }

        it { is_expected.to be true }
      end

      context 'when the has no question answer is no' do
        let(:has_no_answer) { 'no' }

        it { is_expected.to be true }
      end

      context 'when the has no question has not been answered answered' do
        let(:has_no_answer) { nil }

        it { is_expected.to be false }
      end
    end
  end

  describe '#answers' do
    let(:item_component) { Summary::Components.const_get(record.class.name) }
    let(:has_no_answer) { nil }

    context 'when there are records' do
      let(:component) { instance_double(Summary::Components::GroupedList) }

      before do
        allow(Summary::Components::GroupedList).to receive(:new) { component }
      end

      it 'returns the grouped list component with actions' do
        expect(subject.answers).to be component

        expect(Summary::Components::GroupedList).to have_received(:new).with(
          items: records,
          item_component: item_component,
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
            item_component: item_component,
            show_actions: false,
            show_record_actions: false
          )
        end
      end
    end

    context 'when there are no records' do
      let(:records) { [] }
      let(:answers) { subject.answers }
      let(:has_no_answer) { 'yes' }

      it 'has the correct rows' do
        expect(answers.count).to eq(1)

        expect(answers[0]).to be_an_instance_of(Summary::Components::ValueAnswer)
        expect(answers[0].question_text).to eq expected_question_text
        expect(answers[0].answer_text).to eq expected_no_records_answer
        expect(answers[0].change_path).to match expected_change_path
        expect(answers[0].value).to eq(expected_no_records_answer_value)
      end
    end
  end
end
