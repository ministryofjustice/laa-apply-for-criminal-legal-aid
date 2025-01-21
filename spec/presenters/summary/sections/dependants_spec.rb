require 'rails_helper'

describe Summary::Sections::Dependants do
  subject { described_class.new(crime_application) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      to_param: '12345',
      income: income,
      dependants: dependants,
    )
  end
  let(:client_has_dependants) { 'no' }

  let(:income) do
    instance_double(
      Income,
      client_has_dependants:,
    )
  end

  let(:dependants) { [dependant1, dependant2] }

  let(:dependant1) do
    instance_double(
      Dependant,
      age: 17,
    )
  end

  let(:dependant2) do
    instance_double(
      Dependant,
      age: 1,
    )
  end

  describe '#name' do
    it { expect(subject.name).to eq(:dependants) }
  end

  describe '#show?' do
    context 'when there is an income_details' do
      it 'shows this section' do
        expect(subject.show?).to be(true)
      end
    end

    context 'when there is no income_details' do
      let(:income) { nil }

      it 'does not show this section' do
        expect(subject.show?).to be(false)
      end
    end
  end

  describe '#answers' do
    let(:answers) { subject.answers }

    context 'client does not have dependants' do
      let(:dependants) { [] }

      it 'has the correct rows' do
        expect(answers.count).to eq(1)

        expect(answers[0]).to be_an_instance_of(Summary::Components::ValueAnswer)
        expect(answers[0].question).to eq(:client_has_dependants)
        expect(answers[0].change_path).to match('/applications/12345/steps/income/does-client-have-dependants')
        expect(answers[0].value).to eq('no')
      end
    end

    context 'client does have dependants' do
      let(:client_has_dependants) { 'yes' }

      it 'has the correct rows' do
        expect(answers.count).to eq(3)

        expect(answers[0]).to be_an_instance_of(Summary::Components::ValueAnswer)
        expect(answers[0].question).to eq(:client_has_dependants)
        expect(answers[0].change_path).to match('/applications/12345/steps/income/does-client-have-dependants')
        expect(answers[0].value).to eq('yes')

        expect(answers[1]).to be_an_instance_of(Summary::Components::FreeTextAnswer)
        expect(answers[1].question).to eq(:dependant)
        expect(answers[1].change_path).to match('/applications/12345/steps/income/dependants')
        expect(answers[1].value).to eq('17 years old')
        expect(answers[1].i18n_opts[:ordinal]).to eq(1)

        expect(answers[2]).to be_an_instance_of(Summary::Components::FreeTextAnswer)
        expect(answers[2].question).to eq(:dependant)
        expect(answers[2].change_path).to match('/applications/12345/steps/income/dependants')
        expect(answers[2].value).to eq('1 year old')
        expect(answers[2].i18n_opts[:ordinal]).to eq(2)
      end
    end
  end
end
