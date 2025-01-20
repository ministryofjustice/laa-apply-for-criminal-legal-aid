require 'rails_helper'

describe Summary::Sections::Codefendants do
  subject { described_class.new(crime_application) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      in_progress?: true,
      kase: kase,
      to_param: 12_345,
      cifc?: cifc?,
    )
  end

  let(:kase) do
    instance_double(
      Case,
      has_codefendants: has_codefendants,
      codefendants: records,
    )
  end

  let(:records) { [Codefendant.new] }
  let(:has_codefendants) { 'yes' }
  let(:cifc?) { false }

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

    context 'when change in financial circumstances application' do
      let(:cifc?) { true }

      it 'does not show this section' do
        expect(subject.show?).to be(false)
      end
    end
  end

  describe '#answers' do
    context 'when there are codefendants' do
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

    context 'when there are no codefendants' do
      let(:records) { [] }
      let(:answers) { subject.answers }
      let(:has_codefendants) { 'no' }

      it 'has the correct rows' do
        expect(answers.count).to eq(1)

        expect(answers[0]).to be_an_instance_of(Summary::Components::ValueAnswer)
        expect(answers[0].question).to eq(:has_codefendants)
        expect(answers[0].change_path).to match('applications/12345/steps/case/has-codefendants')
        expect(answers[0].value).to eq('no')
      end
    end
  end
end
