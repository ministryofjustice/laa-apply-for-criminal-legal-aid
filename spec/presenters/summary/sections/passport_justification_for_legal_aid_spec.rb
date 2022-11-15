require 'rails_helper'

describe Summary::Sections::PassportJustificationForLegalAid do
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
      ioj:,
      ioj_passport:
    )
  end

  let(:ioj_passport) { ['on_age_under18'] }
  let(:ioj) { nil }

  describe '#name' do
    it { expect(subject.name).to eq(:passport_justification_for_legal_aid) }
  end

  describe '#show?' do
    context 'when there is a case' do
      context 'when there is an ioj present' do
        let(:ioj) { 'foo' }

        it 'does not show this section' do
          expect(subject.show?).to be(false)
        end
      end

      context 'when there is no ioj present' do
        context 'when there is no ioj passport' do
          let(:ioj_passport) { nil }

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
      expect(answers[0]).to be_an_instance_of(Summary::Components::ValueAnswer)
      expect(answers[0].question).to eq(:passport)
    end
  end
end
