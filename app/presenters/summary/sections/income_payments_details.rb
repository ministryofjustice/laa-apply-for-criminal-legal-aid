require 'laa_crime_schemas'

module Summary
  module Sections
    class IncomePaymentsDetails < Sections::PaymentDetails
      private

      def payments
        @payments ||= crime_application.income_payments
      end

      def edit_path
        edit_steps_income_income_payments_path
      end

      def question
        :which_payments
      end

      def anchor_prefix
        '#steps-income-income-payments-form-types-'
      end

      def type_suffix
        '_payment'
      end

      def other_details
        :other_payment_details
      end

      def payment_types
        LaaCrimeSchemas::Types::IncomePaymentType.values
      end
    end
  end
end
