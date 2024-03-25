module Steps
  module Outgoings
    class RentForm < Steps::BaseFormObject
      attribute :amount, :pence
      attribute :frequency, :value_object, source: PaymentFrequencyType

      validate :number?
      validates :amount, presence: true, numericality: { greater_than: 0 }
      validates :frequency, presence: true, inclusion: { in: PaymentFrequencyType.values }

      def self.build(crime_application)
        payment = crime_application.outgoings_payments.rent

        new.tap do |form|
          form.attributes = payment.slice(:amount, :frequency) if payment
        end
      end

      private

      def persist!
        ::OutgoingsPayment.transaction do
          reset!

          crime_application.outgoings_payments.create!(
            payment_type: OutgoingsPaymentType::RENT.value,
            amount: amount,
            frequency: frequency,
          )
        end
      end

      def reset!
        crime_application.outgoings_payments.housing_payments.destroy_all
      end

      def number?
        return true unless non_numeric_string?(amount.to_s)

        errors.add(:amount, :not_a_number)
      end
    end
  end
end
