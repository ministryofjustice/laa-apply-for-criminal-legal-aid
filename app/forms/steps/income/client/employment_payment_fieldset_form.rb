module Steps
  module Income
    module Client
      class EmploymentPaymentFieldsetForm < Steps::BaseFormObject
        attribute :amount, :pence
        attribute :before_or_after_tax, :value_object, source: BeforeOrAfterTax
        attribute :frequency, :value_object, source: PaymentFrequencyType
        attribute :type
        attribute :payment_type
        attribute :crime_application_id

        validates :amount, presence: true
        validates :frequency, presence: true, inclusion: { in: PaymentFrequencyType.values }
        validates :before_or_after_tax, inclusion: { in: BeforeOrAfterTax.values }

        def persist!
          id.present?
        end
      end
    end
  end
end
