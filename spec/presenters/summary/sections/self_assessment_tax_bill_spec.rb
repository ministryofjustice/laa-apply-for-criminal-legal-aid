require 'rails_helper'

describe Summary::Sections::SelfAssessmentTaxBill do
  subject { described_class.new(crime_application) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      to_param: '12345',
      income: income
    )
  end

  let(:income) do
    instance_double(
      Income,
      to_param: '12345',
      applicant_self_assessment_tax_bill: applicant_self_assessment_tax_bill,
      applicant_self_assessment_tax_bill_amount: 100_00,
      applicant_self_assessment_tax_bill_frequency: 'week'
    )
  end

  let(:applicant_self_assessment_tax_bill) { 'yes' }

  describe '#show?' do
    context 'when there is an self_assessment_tax_bill question' do
      context 'when applicant_self_assessment_tax_bill is set to `yes`' do
        let(:applicant_self_assessment_tax_bill) { 'yes' }

        it 'shows this section' do
          expect(subject.show?).to be(true)
        end
      end

      context 'when applicant_self_assessment_tax_bill is set to `no`' do
        let(:applicant_self_assessment_tax_bill) { 'no' }

        it 'shows this section' do
          expect(subject.show?).to be(true)
        end
      end

      context 'when applicant_self_assessment_tax_bill is set to nil' do
        let(:applicant_self_assessment_tax_bill) { nil }

        it 'does not show this section' do
          expect(subject.show?).to be(false)
        end
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

    context 'when there is self assessment tax bill paid' do
      let(:applicant_self_assessment_tax_bill) { 'yes' }

      it 'has the correct rows' do
        expect(answers.count).to eq(2)
        expect(answers[0]).to be_an_instance_of(Summary::Components::ValueAnswer)
        expect(answers[0].question).to eq(:self_assessment_tax_bill)
        expect(answers[0].change_path).to match('applications/12345/steps/income/client/self-assessment-client')
        expect(answers[0].value).to eq('yes')
        expect(answers[1]).to be_an_instance_of(Summary::Components::PaymentAnswer)
        expect(answers[1].question).to eq(:self_assessment_tax_bill_payment)
        expect(answers[1].change_path).to match('applications/12345/steps/income/client/self-assessment-client')
        expect(answers[1].value).to be_an_instance_of(
          Summary::Sections::SelfAssessmentTaxBill::SelfAssessmentTaxBillPayment
        )
      end
    end

    context 'when there is no self assessment tax bill paid' do
      let(:applicant_self_assessment_tax_bill) { 'no' }

      it 'has the correct rows' do
        expect(answers.count).to eq(1)
        expect(answers[0]).to be_an_instance_of(Summary::Components::ValueAnswer)
        expect(answers[0].question).to eq(:self_assessment_tax_bill)
        expect(answers[0].change_path).to match('applications/12345/steps/income/client/self-assessment-client')
        expect(answers[0].value).to eq('no')
      end
    end
  end
end
