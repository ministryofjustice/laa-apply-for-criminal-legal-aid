require 'rails_helper'

describe Summary::Sections::WorkBenefits do
  subject { described_class.new(crime_application) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      to_param: '12345',
      income: income,
      income_payments: income_payments_double
    )
  end

  let(:income_payments_double) { double('income_payments_collection', detect: income_payment) }

  let(:income) do
    instance_double(
      Income,
      applicant_other_work_benefit_received:,
      )
  end

  let(:income_payment) do
    instance_double(
      IncomePayment,
      payment_type: 'work_benefits',
      amount: 234_000,
      frequency: 'yearly'
    )
  end

  let(:applicant_other_work_benefit_received) { nil }

  describe '#show?' do
    context 'when there is an income' do
      context 'when applicant_other_work_benefit_received is set to `yes`' do
        let(:applicant_other_work_benefit_received) { 'yes' }

        it 'shows this section' do
          expect(subject.show?).to be(true)
        end
      end

      context 'when applicant_other_work_benefit_received is set to nil' do
        it 'shows this section' do
          expect(subject.show?).to be(false)
        end
      end
    end

    context 'when there is no income' do
      let(:income) { nil }
      let(:income_payments_double) { [] }

      it 'does not show this section' do
        expect(subject.show?).to be(false)
      end
    end
  end

  describe '#answers' do
    let(:answers) { subject.answers }

    context 'when there is an income' do
      let(:applicant_other_work_benefit_received) { 'yes' }

      it 'has the correct rows' do
        expect(answers.count).to eq(2)
        expect(answers[0]).to be_an_instance_of(Summary::Components::ValueAnswer)
        expect(answers[0].question).to eq(:work_benefits)
        expect(answers[0].change_path).to match('applications/12345/steps/income/client/other_work_benefits_client')
        expect(answers[0].value).to eq('yes')
        expect(answers[1]).to be_an_instance_of(Summary::Components::PaymentAnswer)
        expect(answers[1].question).to eq(:work_benefits_payment)
        expect(answers[1].change_path).to match('applications/12345/steps/income/client/other_work_benefits_client')
        expect(answers[1].value).to eq(income_payment)
      end
    end
  end
end
