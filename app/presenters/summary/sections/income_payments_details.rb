require 'laa_crime_schemas'

module Summary
  module Sections
    class IncomePaymentsDetails < Sections::PaymentDetails
      private

      def payments
        @payments ||= crime_application.income_payments
      end

      def no_payments?
        return false if section.has_no_income_payments.nil?

        YesNoAnswer.new(section.has_no_income_payments).yes?
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

      def payment_types
        LaaCrimeSchemas::Types::IncomePaymentType.values
      end
    end
  end
end
