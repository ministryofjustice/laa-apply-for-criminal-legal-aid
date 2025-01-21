require 'rails_helper'

describe Summary::Sections::PremiumBonds do
  subject { described_class.new(crime_application) }

  let(:crime_application) { instance_double(CrimeApplication, capital: capital, in_progress?: true, to_param: 12_345) }

  let(:capital) do
    instance_double(
      Capital,
      has_premium_bonds: 'yes',
      premium_bonds_holder_number: 'A123',
      premium_bonds_total_value: '10.01'
    )
  end

  describe '#name' do
    it { expect(subject.name).to eq(:premium_bonds) }
  end

  describe '#show?' do
    context 'when there is capital' do
      it 'shows this section' do
        expect(subject.show?).to be(true)
      end
    end

    context 'when there is no capital' do
      let(:capital) { nil }

      it 'does not show this section' do
        expect(subject.show?).to be(false)
      end
    end
  end

  describe '#answers' do
    let(:answers) { subject.answers }

    context 'when client has premium bonds' do
      let(:expected_change_path) do
        'applications/12345/steps/capital/client-any-premium-bonds'
      end

      it 'shows all answers' do
        expect(answers.count).to eq(3)
        expect(answers[0]).to be_an_instance_of(Summary::Components::ValueAnswer)
        expect(answers[0].question).to eq(:has_premium_bonds)
        expect(answers[0].change_path).to match(expected_change_path)
        expect(answers[0].value).to eq('yes')

        expect(answers[1]).to be_an_instance_of(Summary::Components::FreeTextAnswer)
        expect(answers[1].question).to eq(:premium_bonds_holder_number)
        expect(answers[1].change_path).to match(expected_change_path)
        expect(answers[1].value).to eq('A123')

        expect(answers[2]).to be_an_instance_of(Summary::Components::MoneyAnswer)
        expect(answers[2].question).to eq(:premium_bonds_total_value)
        expect(answers[1].change_path).to match(expected_change_path)
        expect(answers[2].value).to eq('10.01')
      end
    end

    context 'when client has no premium bonds' do
      before do
        allow(capital).to receive(:has_premium_bonds).and_return('no')
      end

      it 'has the correct rows' do
        expect(answers.count).to eq(1)
      end
    end
  end
end
