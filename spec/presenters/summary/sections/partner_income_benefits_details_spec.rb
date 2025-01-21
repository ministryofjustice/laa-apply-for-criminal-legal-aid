require 'rails_helper'

describe Summary::Sections::PartnerIncomeBenefitsDetails do
  subject { described_class.new(crime_application) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      to_param: '12345',
      income: income,
      partner: instance_double(Partner),
      partner_detail: instance_double(PartnerDetail, involvement_in_case: 'none'),
      non_means_tested?: false
    )
  end

  let(:income) do
    instance_double(
      Income,
      partner_has_no_income_benefits:,
      income_benefits:
    )
  end

  let(:income_benefits) { [] }
  let(:partner_has_no_income_benefits) { nil }

  describe '#name' do
    it { expect(subject.name).to eq(:partner_income_benefits_details) }
  end

  describe '#show?' do
    context 'when there is no income data' do
      let(:income) { nil }

      it 'shows this section' do
        expect(subject.show?).to be false
      end
    end

    context 'when there are no income benefits' do
      context 'when the question was shown' do
        let(:partner_has_no_income_benefits) { 'yes' }

        it 'shows this section' do
          expect(subject.show?).to be true
        end
      end

      context 'when the question was not shown' do
        it 'does not show this section' do
          expect(subject.show?).to be false
        end
      end
    end
  end

  describe '#answers' do
    let(:answers) { subject.answers }

    context 'when no benefits are reported' do
      let(:partner_has_no_income_benefits) { 'yes' }

      it 'has the correct rows' do
        expect(answers.count).to eq(1)

        expect(answers[0]).to be_an_instance_of(Summary::Components::ValueAnswer)
        expect(answers[0].question).to eq(:which_benefits_partner)
        expect(answers[0].change_path).to match('applications/12345/steps/income/which-benefits-partner')
        expect(answers[0].value).to eq('none')
      end
    end
  end
end
