require 'laa_crime_schemas'

module Summary
  module Sections
    class IncomeBenefitsDetails < Sections::PaymentDetails
      private

      def payments
        @payments ||= crime_application.income_benefits
      end

      def edit_path
        edit_steps_income_income_benefits_path
      end

      def question
        :which_benefits
      end

      def anchor_prefix
        '#steps-income-income-benefits-form-types-'
      end

      def type_suffix
        '_benefit'
      end

      def other_details
        :other_benefits_details
      end

      def payment_types
        LaaCrimeSchemas::Types::IncomeBenefitType.values
      end
    end
  end
end
