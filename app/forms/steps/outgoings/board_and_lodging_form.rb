module Steps
  module Outgoings
    class BoardAndLodgingForm < Steps::BaseFormObject
      include TypeOfMeansAssessment
      include ApplicantAndPartner

      attribute :board_amount, :pence
      attribute :food_amount, :pence
      attribute :frequency, :value_object, source: PaymentFrequencyType
      attribute :payee_name, :string
      attribute :payee_relationship_to_client, :string

      validates :board_amount, presence: true, numericality: { greater_than: 0 }
      validates :food_amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
      validates :frequency, inclusion: { in: PaymentFrequencyType.values }
      validates :payee_name, presence: true
      validates :payee_relationship_to_client, presence: true

      validate :board_greater_than_food

      def board_greater_than_food
        return unless board_amount.present? && food_amount.present?

        errors.add(:food_amount, :more_than_board) if food_amount.to_f > board_amount.to_f
      end

      def self.build(crime_application)
        payment = crime_application.outgoings_payments.board_and_lodging
        form = new(crime_application:)

        if payment
          form.frequency = payment.frequency
          form.food_amount = payment.food_amount
          form.board_amount = payment.board_amount
          form.payee_name = payment.payee_name
          form.payee_relationship_to_client = payment.payee_relationship_to_client
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
            board_amount: board_amount,
            food_amount: food_amount,
          )
        end
      end

      def reset!
        crime_application.outgoings_payments.housing_payments.destroy_all
      end
    end
  end
end
