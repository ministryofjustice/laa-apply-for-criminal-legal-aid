require 'rails_helper'

describe Summary::Sections::TrustFund do
  subject { described_class.new(crime_application) }

  let(:crime_application) { instance_double(CrimeApplication, capital: capital, in_progress?: true, to_param: 12_345) }

  let(:capital) do
    instance_double(
      Capital,
      will_benefit_from_trust_fund: 'yes',
      trust_fund_amount_held: '1000.01',
      trust_fund_yearly_dividend: '100.01'
    )
  end

  describe '#name' do
    it { expect(subject.name).to eq(:trust_fund) }
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

    context 'when client benefits from a trust fund' do
      let(:expected_change_path) do
        'applications/12345/steps/capital/client-benefit-from-trust-fund'
      end

      it 'shows all answers' do
        expect(answers.count).to eq(3)
        expect(answers[0]).to be_an_instance_of(Summary::Components::ValueAnswer)
        expect(answers[0].question).to eq(:will_benefit_from_trust_fund)
        expect(answers[0].change_path).to match(expected_change_path)
        expect(answers[0].value).to eq('yes')

        expect(answers[1]).to be_an_instance_of(Summary::Components::MoneyAnswer)
        expect(answers[1].question).to eq(:trust_fund_amount_held)
        expect(answers[1].change_path).to match(expected_change_path)
        expect(answers[1].value).to eq('1000.01')

        expect(answers[2]).to be_an_instance_of(Summary::Components::MoneyAnswer)
        expect(answers[2].question).to eq(:trust_fund_yearly_dividend)
        expect(answers[1].change_path).to match(expected_change_path)
        expect(answers[2].value).to eq('100.01')
      end
    end

    context 'when client does not benefit from a trust fund' do
      before do
        allow(capital).to receive(:will_benefit_from_trust_fund).and_return('no')
      end

      it 'has the correct rows' do
        expect(answers.count).to eq(1)
      end
    end

    context 'when question has not yet been answered' do
      before do
        allow(capital).to receive(:will_benefit_from_trust_fund).and_return(nil)
      end

      it 'has the correct rows' do
        expect(answers.count).to eq(1)
      end
    end
  end
end
