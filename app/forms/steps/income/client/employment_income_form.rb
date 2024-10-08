module Steps
  module Income
    module Client
      class EmploymentIncomeForm < Steps::BaseFormObject
        attribute :amount, :pence
        attribute :before_or_after_tax, :value_object, source: BeforeOrAfterTax
        attribute :frequency, :value_object, source: PaymentFrequencyType

        validates :amount, numericality: {
          greater_than: 0,
          less_than_or_equal_to: 9_999_999_999.99
        }
        validates :before_or_after_tax, inclusion: { in: :before_or_after_tax_options }
        validates :frequency, inclusion: { in: PaymentFrequencyType.values }

        def before_or_after_tax_options
          BeforeOrAfterTax.values
        end

        def self.build(crime_application)
          payment = crime_application.applicant.income_payments.employment
          form = new

          if payment
            form.amount = payment.amount
            form.before_or_after_tax = payment.before_or_after_tax['value']
            form.frequency = payment.frequency
          end

          form
        end

        private

        def persist!
          ::IncomePayment.transaction do
            reset!

            crime_application.income_payments.create!(
              payment_type: IncomePaymentType::EMPLOYMENT.value,
              amount: amount,
              frequency: frequency,
              before_or_after_tax: before_or_after_tax,
              ownership_type: OwnershipType::APPLICANT.to_s
            )
          end
        end

        def reset!
          crime_application.applicant.income_payments.employment&.destroy
        end
      end
    end
  end
end
