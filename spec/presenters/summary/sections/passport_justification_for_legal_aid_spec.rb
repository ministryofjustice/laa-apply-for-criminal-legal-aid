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

    context 'when there is ioj passport override' do
      let(:ioj) do
        instance_double(
          Ioj,
          types: ioj_types,
          passport_override: true,
        )
      end

      context 'and no justification has been provided yet' do
        let(:ioj_types) { [] }

        it 'has the correct rows' do
          expect(answers.count).to eq(1)
          expect(answers[0]).to be_an_instance_of(Summary::Components::ValueAnswer)
          expect(answers[0].question).to eq(:passport_override)
          expect(answers[0].show?).to be(true)
        end
      end

      context 'and some justification has been provided already' do
        let(:ioj_types) { [:foobar] }

        it 'has the correct rows' do
          expect(answers.count).to eq(0)
        end
      end
    end
  end
end
