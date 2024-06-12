require 'laa_crime_schemas'

module Summary
  module Sections
    class PartnerIncomeBenefitsDetails < Sections::PaymentDetails
      def show?
        true # TODO: Requires adjusting once partner journey in place
      end

      private

      def payments
        @payments ||= crime_application.income_benefits.select { |i| i.ownership_type == OwnershipType::PARTNER.to_s }
      end

      def no_payments?
        payments.none?
      end

      def edit_path
        edit_steps_income_partner_income_benefits_path
      end

      def question
        :which_benefits_partner
      end

      def anchor_prefix
        '#steps-income-partner-income-benefits-form-types-'
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
