module Steps
  module Income
    class IncomePaymentsForm < Steps::BaseFormObject
      #include Steps::HasOneAssociation
      #has_one_association :crime_application

      delegate :income_payment_details_attributes=, to: :crime_application

      attribute :income_payment_type, array: true, default: []

      def xincome_payment_details
        binding.break
        # income_payment_type = IncomePaymentType.values.find { |t| t.to_s == payment_type.to_s }
        # income_payment = IncomePayment.new(payment_type: income_payment_type.to_s, crime_application_id: crime_application)
        # IncomePaymentFieldsetForm.build(income_payment, crime_application:)

        IncomePaymentType.values.map do |income_type|
          income_payment = IncomePayment.new(payment_type: income_type.to_s, crime_application_id: crime_application.id)
          IncomePaymentFieldsetForm.build(income_payment, crime_application:)
        end

        # @income_payment_details ||= crime_application.income_payments.map do |payment|
        #   IncomePaymentFieldsetForm.build(
        #     payment, crime_application:
        #   )
        # end
      end

      def maintainance
        binding.break
        income_payment_type = IncomePaymentType.values.find { |t| t.to_s == 'maintainance' }
        income_payment = IncomePayment.new(payment_type: income_payment_type.to_s, crime_application_id: crime_application)
        IncomePaymentFieldsetForm.build(income_payment, crime_application:)
      end
      def private_pension
        binding.break
        income_payment_type = IncomePaymentType.values.find { |t| t.to_s == 'state_pension' }
        income_payment = IncomePayment.new(payment_type: income_payment_type.to_s, crime_application_id: crime_application)
        IncomePaymentFieldsetForm.build(income_payment, crime_application:)
      end
      def state_pension
        binding.break
        income_payment_type = IncomePaymentType.values.find { |t| t.to_s == 'state_pension' }
        income_payment = IncomePayment.new(payment_type: income_payment_type.to_s, crime_application_id: crime_application)
        IncomePaymentFieldsetForm.build(income_payment, crime_application:)
      end

      private

      def persist!
        crime_application.save
      end
    end
  end
end
