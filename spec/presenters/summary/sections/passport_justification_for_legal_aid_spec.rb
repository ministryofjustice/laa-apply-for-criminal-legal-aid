require 'rails_helper'

describe Summary::Sections::PassportJustificationForLegalAid do
  subject { described_class.new(crime_application) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      to_param: '12345',
      ioj_passport: ioj_passport,
      ioj: ioj,
    )
  end

  let(:ioj_passport) { ['foobar'] }
  let(:ioj) { nil }

  describe '#name' do
    it { expect(subject.name).to eq(:passport_justification_for_legal_aid) }
  end

  describe '#show?' do
    context 'when there is an ioj present' do
      let(:ioj) { 'foo' }

      it 'does not show this section' do
        expect(subject.show?).to be(false)
      end
    end

    context 'when there is no ioj present' do
      context 'when there is no ioj passport' do
        let(:ioj_passport) { [] }

        it 'does not show this section' do
          expect(subject.show?).to be(false)
        end
      end

      context 'when there is an ioj passport' do
        it 'shows this section' do
          expect(subject.show?).to be(true)
        end
      end
    end
  end

  describe '#answers' do
    let(:answers) { subject.answers }

    context 'when there is ioj passport' do
      it 'has the correct rows' do
        expect(answers.count).to eq(1)
        expect(answers[0]).to be_an_instance_of(Summary::Components::ValueAnswer)
        expect(answers[0].question).to eq(:passport)
        expect(answers[0].show?).to be(true)
      end
    end

    context 'when there is no ioj passport' do
      let(:ioj_passport) { [] }

      it 'has the correct rows' do
        expect(answers.count).to eq(0)
      end
    end
  end
end
