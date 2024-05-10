require 'laa_crime_schemas'

module Summary
  module Sections
    class IncomeBenefitsDetails < Sections::PaymentDetails
      def show?
        return false
        return false if income.blank?

        income.has_no_income_benefits == 'yes' || super
      end

      private

      def payments
        @payments ||= crime_application.income_benefits
      end

      def no_payments?
        return false if income.has_no_income_benefits.nil?

        YesNoAnswer.new(income.has_no_income_benefits).yes?
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

      def payment_types
        LaaCrimeSchemas::Types::IncomeBenefitType.values
      end
    end
  end
end
