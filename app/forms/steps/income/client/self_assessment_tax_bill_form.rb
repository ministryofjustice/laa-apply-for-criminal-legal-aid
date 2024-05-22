module Steps
  module Income
    module Client
      class SelfAssessmentTaxBillForm < Steps::BaseFormObject
        attribute :applicant_self_assessment_tax_bill, :value_object, source: YesNoAnswer
        attribute :amount, :pence
        attribute :frequency, :value_object, source: PaymentFrequencyType

        validates :applicant_self_assessment_tax_bill, inclusion: { in: YesNoAnswer.values }
        validates :amount, numericality: { greater_than: 0 }, if: -> { pays_self_assessment_tax_bill? }
        validates :frequency, inclusion: { in: PaymentFrequencyType.values }, if: -> { pays_self_assessment_tax_bill? }

        def self.build(crime_application)
          payment = crime_application.outgoings_payments.self_assessment_tax_bill
          income = crime_application.income
          form = new

          form.applicant_self_assessment_tax_bill = income.applicant_self_assessment_tax_bill if income

          if payment
            form.amount = payment.amount
            form.frequency = payment.frequency
          end

          form
        end

        private

        def pays_self_assessment_tax_bill?
          applicant_self_assessment_tax_bill&.yes?
        end

        def persist!
          crime_application.income.update(
            applicant_self_assessment_tax_bill:,
          )

          persist_outgoings_payment if pays_self_assessment_tax_bill?
        end

        def persist_outgoings_payment
          ::OutgoingsPayment.transaction do
            reset!

            crime_application.outgoings_payments.create!(
              payment_type: OutgoingsPaymentType::SELF_ASSESSMENT_TAX_BILL.value,
              amount: amount,
              frequency: frequency,
            )
          end
        end

        def reset!
          crime_application.outgoings_payments.self_assessment_tax_bill&.destroy
        end

        def before_save
          return if pays_self_assessment_tax_bill?

          self.amount = nil
          self.frequency = nil
        end
      end
    end
  end
end
