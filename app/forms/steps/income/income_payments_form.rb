module Steps
  module Income
    class IncomePaymentsForm < Steps::BaseFormObject
      delegate :income_payments_attributes=, to: :crime_application

      attribute :income_payment, array: true, default: []

      IncomePaymentType.values.each do |type|
        attribute type.to_s, :string
      end

      def income_payments
        @income_payments ||= crime_application.income_payments.map do |income_payment|
          IncomePaymentFieldsetForm.build(
            income_payment, crime_application:
          )
        end
      end

      private

      def persist!
        crime_application.income_payments = []

        ::CrimeApplication.transaction do
          income_payment.compact_blank.each do |type|
            crime_application.income_payments << IncomePayment.new(
              @attributes[type].value_before_type_cast.merge(payment_type: type.to_s)
            )
          end

          crime_application.save!
        end
      end
    end
  end
end
