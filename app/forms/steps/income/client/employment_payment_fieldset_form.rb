module Steps
  module Income
    module Client
      class EmploymentPaymentFieldsetForm < Steps::BaseFormObject
        attribute :amount, :pence
        attribute :before_or_after_tax, :value_object, source: BeforeOrAfterTax
        attribute :frequency, :value_object, source: PaymentFrequencyType

        validates :amount, numericality: { greater_than: 0 }
        validates :before_or_after_tax, inclusion: { in: BeforeOrAfterTax.values }
        validates :frequency, presence: true, inclusion: { in: PaymentFrequencyType.values }
      end
    end
  end
end
