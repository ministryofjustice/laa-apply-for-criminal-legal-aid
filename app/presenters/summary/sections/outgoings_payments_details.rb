module Summary
  module Sections
    class OutgoingsPaymentsDetails < Sections::PaymentDetails
      private

      def section
        @section ||= crime_application.outgoings
      end

      def no_payments?
        return false if section.has_no_other_outgoings.nil?

        YesNoAnswer.new(section.has_no_other_outgoings).yes?
      end

      def payments
        @payments ||= crime_application.outgoings_payments.select { |p| payment_types.include? p.payment_type }
      end

      def edit_path
        edit_steps_outgoings_outgoings_payments_path
      end

      def question
        :which_outgoings
      end

      def anchor_prefix
        '#steps-outgoings-outgoings-payments-form-types-'
      end

      def type_suffix
        '_outgoing'
      end

      def payment_types
        %w[childcare maintenance legal_aid_contribution]
      end
    end
  end
end
