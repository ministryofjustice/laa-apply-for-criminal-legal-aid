module Steps
  module Income
    module Client
      class EmploymentDetailsForm < Steps::BaseFormObject
        attribute :job_title

        delegate :income_payment_attributes=, to: :record

        def income_payment
          payment = record.income_payment.nil? ? record.build_income_payment : record.income_payment
          @income_payment ||= EmploymentPaymentFieldsetForm.build(payment, crime_application:)
        end

        validates :job_title, presence: true
        validates_with EmploymentPaymentValidator

        def before_or_after_tax_options
          BeforeOrAfterTax.values
        end

        def persist!
          reset!

          record.income_payment.crime_application = crime_application
          record.income_payment.payment_type = IncomePaymentType::EMPLOYMENT_INCOME.to_s
          record.job_title = attributes['job_title']
          record.save
        end

        def reset!
          crime_application.employments.where(id: record.id).find_each do |employment|
            employment.income_payment&.destroy
          end
        end
      end
    end
  end
end
