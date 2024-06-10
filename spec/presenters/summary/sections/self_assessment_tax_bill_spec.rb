require 'rails_helper'

describe Summary::Sections::SelfAssessmentTaxBill do
  subject { described_class.new(crime_application) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      to_param: '12345',
      outgoings: outgoings,
      outgoings_payments: outgoings_payments_double
    )
  end

  let(:outgoings_payments_double) { double('outgoings_payments_collection', detect: outgoings_payment) }

  let(:outgoings) do
    instance_double(
      Outgoings,
      applicant_self_assessment_tax_bill:,
    )
  end

  let(:outgoings_payment) do
    instance_double(
      OutgoingsPayment,
      payment_type: 'self_assessment_tax_bill',
      amount: 234_000,
      frequency: 'yearly'
    )
  end

  let(:applicant_self_assessment_tax_bill) { nil }

  describe '#show?' do
    context 'when there is an outgoings' do
      context 'when applicant_self_assessment_tax_bill is set to `yes`' do
        let(:applicant_self_assessment_tax_bill) { 'yes' }

        it 'shows this section' do
          expect(subject.show?).to be(true)
        end
      end

      context 'when applicant_self_assessment_tax_bill is set to nil' do
        it 'shows this section' do
          expect(subject.show?).to be(false)
        end
      end
    end

    context 'when there is no outgoings' do
      let(:outgoings) { nil }
      let(:outgoings_payments_double) { [] }

      it 'does not show this section' do
        expect(subject.show?).to be(false)
      end
    end
  end

  describe '#answers' do
    let(:answers) { subject.answers }

    context 'when there are outgoings' do
      let(:applicant_self_assessment_tax_bill) { 'yes' }

      it 'has the correct rows' do
        expect(answers.count).to eq(2)
        expect(answers[0]).to be_an_instance_of(Summary::Components::ValueAnswer)
        expect(answers[0].question).to eq(:self_assessment_tax_bill)
        expect(answers[0].change_path).to match('applications/12345/steps/income/client/self_assessment_client')
        expect(answers[0].value).to eq('yes')
        expect(answers[1]).to be_an_instance_of(Summary::Components::PaymentAnswer)
        expect(answers[1].question).to eq(:self_assessment_tax_bill_payment)
        expect(answers[1].change_path).to match('applications/12345/steps/income/client/self_assessment_client')
        expect(answers[1].value).to eq(outgoings_payment)
      end
    end
  end
end
