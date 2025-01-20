require 'rails_helper'

describe Summary::Sections::PartnerEmploymentIncome do
  subject { described_class.new(crime_application) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      to_param: '12345',
      income: income,
    )
  end

  let(:income) { instance_double(Income, partner_employment_income: income_payment) }

  let(:income_payment) do
    instance_double(
      IncomePayment,
      payment_type: 'employment',
      amount: 234_000,
      frequency: 'yearly',
      ownership_type: 'partner'
    )
  end

  let(:partner_other_work_benefit_received) { nil }

  describe '#show?' do
    context 'when employment income_payment is present' do
      it 'shows this section' do
        expect(subject.show?).to be(true)
      end
    end

    context 'when employment income_payment is not present' do
      let(:income_payment) { nil }

      it 'does not show this section' do
        expect(subject.show?).to be(false)
      end
    end

    context 'when there is no income' do
      let(:income) { nil }

      it 'does not show this section' do
        expect(subject.show?).to be(false)
      end
    end
  end

  describe '#answers' do
    let(:answers) { subject.answers }

    context 'when there is an employment income' do
      let(:partner_other_work_benefit_received) { 'yes' }

      it 'has the correct rows' do
        expect(answers.count).to eq(1)
        expect(answers[0]).to be_an_instance_of(Summary::Components::PaymentAnswer)
        expect(answers[0].question).to eq(:partner_employment_income)
        expect(answers[0].change_path).to match('applications/12345/steps/income/partner/employment-income')
        expect(answers[0].value).to eq(income_payment)
      end
    end
  end
end
