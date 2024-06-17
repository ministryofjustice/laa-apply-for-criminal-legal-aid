require 'laa_crime_schemas'

module Summary
  module Sections
    class PartnerIncomePaymentsDetails < Sections::PaymentDetails
      include TypeOfMeansAssessment

      def show?
        return false unless FeatureFlags.partner_journey.enabled?

        include_partner_in_means_assessment?
      end

      private

      def payments
        @payments ||= crime_application.income_payments.select { |i| i.ownership_type == OwnershipType::PARTNER.to_s }
      end

      def no_payments?
        payments.none?
      end

      def edit_path
        edit_steps_income_income_payments_partner_path
      end

      def question
        :which_payments_partner
      end

      def anchor_prefix
        '#steps-income-partner-income-payments-form-types-'
      end

      def type_suffix
        '_payment'
      end

      def payment_types
        LaaCrimeSchemas::Types::OtherIncomePaymentType.values
      end
    end
  end
end
