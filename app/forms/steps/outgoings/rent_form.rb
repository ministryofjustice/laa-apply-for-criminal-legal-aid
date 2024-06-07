module Steps
  module Outgoings
    class RentForm < Steps::BaseFormObject
      include TypeOfMeansAssessment
      include ApplicantAndPartner

      attribute :amount, :pence
      attribute :frequency, :value_object, source: PaymentFrequencyType

      validates :amount, presence: true, numericality: { greater_than: 0 }
      validates :frequency, presence: true, inclusion: { in: PaymentFrequencyType.values }

      def self.build(crime_application)
        payment = crime_application.outgoings_payments.rent

        new(crime_application:).tap do |form|
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
    end
  end
end
