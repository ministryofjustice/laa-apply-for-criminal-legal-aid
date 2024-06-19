require 'rails_helper'

describe Summary::Sections::Employments do
  subject { described_class.new(crime_application) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      client_employments: records,
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
      let(:component) { instance_double(Summary::Components::Employment) }

      before do
        allow(Summary::Components::Employment).to receive(:with_collection) { component }
      end

      it 'returns the grouped list component with actions' do
        expect(subject.answers).to be component

        expect(Summary::Components::Employment).to have_received(:with_collection).with(
          records, show_actions: true, show_record_actions: false
        )
      end

      context 'not in progress' do
        before do
          allow(crime_application).to receive(:in_progress?).and_return(false)
        end

        it 'returns the grouped list component without actions' do
          expect(subject.answers).to be component

          expect(Summary::Components::Employment).to have_received(:with_collection).with(
            records, show_actions: false, show_record_actions: false
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
