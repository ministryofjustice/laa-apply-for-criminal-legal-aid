require 'rails_helper'

describe Summary::Sections::OtherIncomeDetails do
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
      manage_without_income: 'other',
      manage_other_details: 'Another way they manage',
    )
  end

  describe '#name' do
    it { expect(subject.name).to eq(:other_income_details) }
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
        expect(answers.count).to eq(2)
        expect(answers[0]).to be_an_instance_of(Summary::Components::ValueAnswer)
        expect(answers[0].question).to eq(:manage_without_income)
        expect(answers[0].change_path).to match('applications/12345/steps/income/how_manage_with_no_income')
        expect(answers[0].value).to eq('other')
        expect(answers[1]).to be_an_instance_of(Summary::Components::FreeTextAnswer)
        expect(answers[1].question).to eq(:manage_other_details)
        expect(answers[1].change_path).to match('applications/12345/steps/income/how_manage_with_no_income')
        expect(answers[1].value).to eq('Another way they manage')
      end
    end
  end
end
