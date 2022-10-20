require 'rails_helper'

describe Summary::Sections::Offences do
  subject { described_class.new(crime_application) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      to_param: '12345',
      case: kase,
    )
  end

  let(:kase) do
    instance_double(
      Case,
      charges: [charge],
    )
  end

  let(:charge) do
    instance_double(
      Charge,
      to_param: '321',
    )
  end

  let(:complete) { true }

  before do
    allow(charge).to receive(:complete?).and_return(complete)
  end

  describe '#name' do
    it { expect(subject.name).to eq(:offences) }
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
    let(:answers) { subject.answers }

    it 'has the correct rows' do
      expect(answers.count).to eq(1)

      expect(answers[0]).to be_an_instance_of(Summary::Components::OffenceAnswer)
      expect(answers[0].question).to eq(:offence_details)
      expect(answers[0].change_path).to match('applications/12345/steps/case/charges/321')
      expect(answers[0].value).to be_an_instance_of(ChargePresenter)
      expect(answers[0].i18n_opts).to eq({ index: 1 })
    end

    context 'when the charge is not complete' do
      let(:complete) { false }

      it 'does not show the row' do
        expect(answers.count).to eq(0)
      end
    end
  end
end
