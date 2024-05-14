module Steps
  module Income
    module Client
      class EmploymentDetailsForm < Steps::BaseFormObject
        attribute :job_title

        delegate :payments_attributes=, to: :record

        def payments
          record.payments.new if record.payments.empty?
          @payments ||= record.payments.map do |payment|
            PaymentFieldsetForm.build(
              payment, crime_application:
            )
          end
        end

        validates :job_title, presence: true

        def persist!
          record.update(attributes)
        end
      end
    end
  end
end
