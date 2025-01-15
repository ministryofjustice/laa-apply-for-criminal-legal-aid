require 'rails_helper'

describe Summary::Sections::OtherIncomeDetails do
  subject(:section) { described_class.new(crime_application) }

  let(:include_partner?) { false }

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

  before do
    allow(section).to receive(:include_partner_in_means_assessment?).and_return(include_partner?)
  end

  describe '#name' do
    it { expect(section.name).to eq(:other_income_details) }
  end

  describe '#show?' do
    context 'when there is an income_details' do
      it 'shows this section' do
        expect(section.show?).to be(true)
      end
    end

    context 'when there is no income_details' do
      let(:income) { nil }

      it 'does not show this section' do
        expect(section.show?).to be(false)
      end
    end
  end

  describe '#answers' do
    let(:answers) { section.answers }

    context 'when there are income details' do
      it 'has the correct rows' do
        expect(answers.count).to eq(2)
        expect(answers[0]).to be_an_instance_of(Summary::Components::ValueAnswer)
        expect(answers[0].question).to eq(:manage_without_income)
        expect(answers[0].change_path).to match('applications/12345/steps/income/how-manage-with-no-income')
        expect(answers[0].value).to eq('other')
        expect(answers[1]).to be_an_instance_of(Summary::Components::FreeTextAnswer)
        expect(answers[1].question).to eq(:manage_other_details)
        expect(answers[1].change_path).to match('applications/12345/steps/income/how-manage-with-no-income')
        expect(answers[1].value).to eq('Another way they manage')
      end
    end
  end

  describe 'the manage without income label' do
    subject(:label) { section.answers.first.question_text }

    context 'when partner is included in means assessment' do
      let(:include_partner?) { true }

      it { is_expected.to eq 'How client and partner live with no income' }
    end

    context 'when partner is not included means assessment' do
      let(:include_partner?) { false }

      it { is_expected.to eq 'How client lives with no income' }
    end
  end
end
