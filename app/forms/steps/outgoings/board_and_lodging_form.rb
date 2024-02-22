module Steps
  module Outgoings
    class BoardAndLodgingForm < Steps::BaseFormObject
      attribute :board_amount, :pence
      attribute :food_amount, :pence
      attribute :frequency, :value_object, source: PaymentFrequencyType
      attribute :payee_name, :string
      attribute :payee_relationship_to_client, :string

      validates :board_amount, presence: true
      validates :food_amount, presence: true
      validates :frequency, inclusion: { in: PaymentFrequencyType.values }
      validates :payee_name, presence: true
      validates :payee_relationship_to_client, presence: true

      # extract the values from OutgoingsPayment.details hash if they already exist
      # and use to set the form attributes on load
      def self.build(crime_application)
        outgoings_payment = crime_application.outgoings_payments.find_by(
          payment_type: OutgoingsPaymentType::BOARD_AND_LODGING.to_s
        )
        form = new

        if outgoings_payment
          form.frequency = outgoings_payment.frequency
          outgoings_payment.details&.each do |attr_name, value|
            form.send("#{attr_name}=", value)
          end
        end

        form
      end

      private

      def amount
        board_amount.to_f - food_amount.to_f
      end

      def persist!
        outgoings_payment = crime_application.outgoings_payments.find_by(
          payment_type: OutgoingsPaymentType::BOARD_AND_LODGING.to_s
        )
        outgoings_payment.update!(
          amount: amount,
          frequency: frequency,
          details: attributes.slice('board_amount', 'food_amount', 'payee_name', 'payee_relationship_to_client')
        )
      end
    end
  end
end
