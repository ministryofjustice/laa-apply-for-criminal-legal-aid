module Summary
  module Sections
    class OutgoingsPaymentsDetails < Sections::PaymentDetails
      include TypeOfMeansAssessment

      def show?
        return false if outgoings.blank?

        outgoings.has_no_other_outgoings == 'yes' || super
      end

      private

      def no_payments?
        return false if outgoings.has_no_other_outgoings.nil?

        YesNoAnswer.new(outgoings.has_no_other_outgoings).yes?
      end

      def payments
        @payments ||= crime_application.outgoings.outgoings_payments.select do |p|
          payment_types.include? p.payment_type
        end
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

      def subject_type
        return super unless include_partner_in_means_assessment?

        SubjectType.new(:applicant_and_partner)
      end
    end
  end
end
