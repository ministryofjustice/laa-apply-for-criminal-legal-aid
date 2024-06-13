require 'rails_helper'

RSpec.describe Steps::Income::Client::SelfAssessmentTaxBillForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application:,
      applicant_self_assessment_tax_bill:,
      amount:,
      frequency:,
    }
  end

  let(:crime_application) { CrimeApplication.new }
  let(:outgoings) { Outgoings.new(crime_application:) }
  let(:outgoings_payment) {
    OutgoingsPayment.new(crime_application: crime_application,
                         payment_type: OutgoingsPaymentType::SELF_ASSESSMENT_TAX_BILL.to_s)
  }

  let(:applicant_self_assessment_tax_bill) { nil }
  let(:amount) { nil }
  let(:frequency) { nil }

  before do
    allow(crime_application.outgoings_payments).to receive(:find_by).with(
      { payment_type: OutgoingsPaymentType::SELF_ASSESSMENT_TAX_BILL.to_s }
    ).and_return(outgoings_payment)
  end

  describe '#build' do
    subject(:form) { described_class.build(crime_application) }

    let(:existing_outgoings_payment) {
      OutgoingsPayment.new(crime_application: crime_application,
                           payment_type: OutgoingsPaymentType::SELF_ASSESSMENT_TAX_BILL.to_s,
                           amount: 50,
                           frequency: 'four_weeks')
    }

    before do
      allow(crime_application.outgoings_payments).to(
        receive(:self_assessment_tax_bill).and_return(existing_outgoings_payment)
      )
      outgoings.applicant_self_assessment_tax_bill = 'yes'
    end

    it 'sets the form attributes from the model' do
      expect(form.amount).to eq Money.new(50)
      expect(form.frequency).to eq(PaymentFrequencyType::FOUR_WEEKLY)
      expect(form.applicant_self_assessment_tax_bill).to eq(YesNoAnswer::YES)
    end
  end

  describe '#save' do
    before do
      allow(crime_application.outgoings_payments).to receive(:create!).and_return(true)
    end

    context 'when `applicant_self_assessment_tax_bill` is not provided' do
      let(:applicant_self_assessment_tax_bill) { nil }

      it 'returns false' do
        expect(form.save).to be(false)
      end

      it 'has a validation error on the field' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:applicant_self_assessment_tax_bill, :inclusion)).to be(true)
      end
    end

    context 'when `applicant_self_assessment_tax_bill` is `Yes`' do
      let(:applicant_self_assessment_tax_bill) { YesNoAnswer::YES.to_s }

      context 'when `amount` is not provided' do
        it 'returns false' do
          expect(form.save).to be(false)
        end

        it 'has a validation error on the field' do
          expect(form).not_to be_valid
          expect(form.errors.of_kind?(:amount, :not_a_number)).to be(true)
        end
      end

      context 'when `frequency` is not valid' do
        let(:frequency) { 'every six weeks' }

        it 'returns false' do
          expect(form.save).to be(false)
        end

        it 'has a validation error on the field' do
          expect(form).not_to be_valid
          expect(form.errors.of_kind?(:frequency, :inclusion)).to be(true)
        end
      end

      context 'when all attributes are valid' do
        let(:amount) { '100' }
        let(:frequency) { PaymentFrequencyType::MONTHLY.to_s }

        it { is_expected.to be_valid }

        it 'passes validation' do
          expect(form.errors.of_kind?(:amount, :invalid)).to be(false)
        end

        context 'when crime_application.outgoings is present' do
          before do
            allow(crime_application).to receive(:outgoings).and_return(outgoings)
          end

          it 'updates the outgoings payment with the correct attributes' do
            expect(crime_application.outgoings_payments).to receive(:create!).with(
              payment_type: :self_assessment_tax_bill,
              amount: Money.new(100_00),
              frequency: PaymentFrequencyType::MONTHLY,
            )
            form.save
          end
        end

        context 'when crime_application.outgoings is not present' do
          let(:outgoings) { nil }

          it 'creates an outgoings with the correct attributes' do
            expect(crime_application).to receive(:create_outgoings!).with(
              applicant_self_assessment_tax_bill: YesNoAnswer::YES
            )
            form.save
          end
        end
      end
    end

    context 'when `applicant_self_assessment_tax_bill` is `No`' do
      let(:applicant_self_assessment_tax_bill) { YesNoAnswer::NO.to_s }

      context 'when `amount` is not provided' do
        it 'passes validation' do
          expect(form.errors.of_kind?(:amount, :invalid)).to be(false)
        end
      end

      context 'when `frequency` is not valid' do
        let(:frequency) { 'every six weeks' }

        it 'passes validation' do
          expect(form.errors.of_kind?(:amount, :invalid)).to be(false)
        end
      end

      context 'when previous values have been recorded' do
        let(:existing_outgoings_payment) {
          OutgoingsPayment.new(crime_application: crime_application,
                               payment_type: OutgoingsPaymentType::SELF_ASSESSMENT_TAX_BILL.to_s,
                               amount: 50,
                               frequency: 'four_weeks')
        }

        before do
          allow(crime_application.outgoings_payments).to(
            receive(:self_assessment_tax_bill).and_return(existing_outgoings_payment)
          )
        end

        it 'resets the attributes before saving' do
          form.send(:before_save)
          expect(form.attributes['amount']).to be_nil
          expect(form.attributes['frequency']).to be_nil
        end
      end
    end
  end
end
