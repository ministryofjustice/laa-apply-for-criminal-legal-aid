require 'rails_helper'

describe Summary::Sections::IncomeDetails do
  subject { described_class.new(crime_application) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      to_param: '12345',
      income: income,
    )
  end

  let(:income) do
    instance_double(
      Income,
      income_above_threshold: 'yes'
    )
  end

  describe '#name' do
    it { expect(subject.name).to eq(:income_details) }
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

    context 'when there are income details' do
      it 'has the correct rows' do
        expect(answers.count).to eq(1)
        expect(answers[0]).to be_an_instance_of(Summary::Components::ValueAnswer)
        expect(answers[0].question).to eq(:income_above_threshold)
        expect(answers[0].change_path).to match('applications/12345/steps/income/clients_income_before_tax')
        expect(answers[0].value).to eq('yes')
      end
    end
  end
end
