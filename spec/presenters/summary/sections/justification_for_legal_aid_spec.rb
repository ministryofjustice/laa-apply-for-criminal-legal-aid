require 'rails_helper'

describe Summary::Sections::JustificationForLegalAid do
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
      ioj:
    )
  end

  let(:ioj) do
    Ioj.new(
      types: %w[reputation other],
      reputation_justification: 'A justification',
      other_justification: 'Another justification'
    )
  end

  before do
    allow(ioj).to receive('reputation_justification').and_return('A justification')
    allow(ioj).to receive('other_justification').and_return('Another justification')
  end

  describe '#name' do
    it { expect(subject.name).to eq(:justification_for_legal_aid) }
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
      expect(answers.count).to eq(2)

      expect(answers[0]).to be_an_instance_of(Summary::Components::FreeTextAnswer)
      expect(answers[0].question).to eq(:ioj_justification)
      expect(answers[0].change_path).to match('applications/12345/steps/case/ioj')
      expect(answers[0].i18n_opts).to eq(ioj_type: 'Reputation')

      expect(answers[1]).to be_an_instance_of(Summary::Components::FreeTextAnswer)
      expect(answers[1].question).to eq(:ioj_justification)
      expect(answers[1].change_path).to match('applications/12345/steps/case/ioj')
      expect(answers[1].i18n_opts).to eq(ioj_type: 'Other')
    end
  end
end
