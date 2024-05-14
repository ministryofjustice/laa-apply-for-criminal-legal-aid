module Steps
  module Income
    module Client
      class EmploymentDetailsForm < Steps::BaseFormObject
        attribute :job_title
        #attribute :income_payment

        delegate :income_payment_attributes=, to: :record

        def income_payment
          payment = if record.income_payment.nil?
                      record.build_income_payment(
                        payment_type: IncomePaymentType::EMPLOYMENT_DETAILS.to_s,
                        crime_application: crime_application
                      )
                    else
                      record.income_payment
                    end
          @income_payment ||= PaymentFieldsetForm.build(payment, crime_application:)
        end

        validates :job_title, presence: true

        def persist!
          record.job_title = attributes['job_title']
          record.save
        end
      end
    end
  end
end
