require 'rails_helper'

describe Summary::Sections::JustificationForLegalAid do
  subject { described_class.new(crime_application) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      to_param: '12345',
      ioj: ioj,
    )
  end

  let(:ioj) do
    Ioj.new(
      types: %w[reputation other],
      reputation_justification: 'A justification',
      other_justification: 'Another justification'
    )
  end

  describe '#name' do
    it { expect(subject.name).to eq(:justification_for_legal_aid) }
  end

  describe '#show?' do
    context 'when there is an ioj' do
      it 'shows this section' do
        expect(subject.show?).to be(true)
      end
    end

    context 'when there is no ioj' do
      let(:ioj) { nil }

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
      expect(answers[0].question).to be_a(IojReasonType)
      expect(answers[0].question).to have_attributes(value: :reputation)
      expect(answers[0].change_path).to match('applications/12345/steps/case/ioj#reputation')

      expect(answers[1]).to be_an_instance_of(Summary::Components::FreeTextAnswer)
      expect(answers[1].question).to be_a(IojReasonType)
      expect(answers[1].question).to have_attributes(value: :other)
      expect(answers[1].change_path).to match('applications/12345/steps/case/ioj#other')
    end
  end
end
