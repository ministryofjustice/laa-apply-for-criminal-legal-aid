module Steps
  module Income
    module Client
      class EmploymentPaymentFieldsetForm < Steps::BaseFormObject
        attribute :amount, :pence
        attribute :frequency, :value_object, source: PaymentFrequencyType
        attribute :type
        attribute :payment_type
        attribute :crime_application_id

        validates :amount, :frequency, presence: true

        def persist!
          id.present?
        end
      end
    end
  end
end
