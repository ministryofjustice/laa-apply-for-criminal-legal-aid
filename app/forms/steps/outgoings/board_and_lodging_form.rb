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

          outgoings_payment.metadata&.each do |attr_name, value|
            form.send(:"#{attr_name}=", value)
          end
        end

        form
      end

      private

      def amount
        board_amount.to_f - food_amount.to_f
      end

      def persist!
        ::OutgoingsPayment.transaction do
          reset!

          crime_application.outgoings_payments.create!(
            payment_type: OutgoingsPaymentType::BOARD_AND_LODGING.value,
            amount: amount,
            frequency: frequency,
            payee_name: payee_name,
            payee_relationship_to_client: payee_relationship_to_client,
            board_amount: Type::Pence.new.serialize(board_amount),
            food_amount: Type::Pence.new.serialize(food_amount),
          )
        end
      end

      def reset!
        crime_application.outgoings_payments.housing_payments.destroy_all
      end
    end
  end
end
