require 'laa_crime_schemas'

module Summary
  module Sections
    class PartnerIncomePaymentsDetails < Sections::PaymentDetails
      include TypeOfMeansAssessment
      include HasDynamicSubject

      def show?
        return false if income.blank?
        return false unless include_partner_in_means_assessment?

        income.partner_has_no_income_payments == 'yes' || super
      end

      private

      def payments
        @payments ||= income.income_payments.select { |i| i.ownership_type == OwnershipType::PARTNER.to_s }
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
        Types::OtherIncomePaymentType.values
      end

      def subject_type
        SubjectType.new(:partner)
      end
    end
  end
end
