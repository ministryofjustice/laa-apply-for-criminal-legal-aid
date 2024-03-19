module Steps
  module Outgoings
    class OutgoingsPaymentsForm < Steps::BaseFormObject
      # NOTE: Remember to add any new types to this list otherwise it will not show on page edit
      PAYMENT_TYPES_ORDER = %w[
        childcare
        maintenance
        legal_aid_contribution
      ].freeze

      attribute :outgoings_payments, array: true, default: [] # Used by BaseFormObject
      attribute :types, array: true, default: [] # Used by edit.html.erb to represent selected checkbox value
      attr_reader :new_payments

      validates_with OutgoingsPaymentsValidator

      OutgoingsPaymentType::OTHER_PAYMENT_TYPES.each do |type|
        attribute type.to_s, :string

        # Used by govuk form component to retrieve values to populate the fields_for
        # for each type (on page load). Trigger validation on load.
        define_method :"#{type}" do
          OutgoingPaymentFieldsetForm.build(find_or_create_outgoings_payment(type), crime_application:).tap do |record|
            record.valid? if types.include?(type.to_s)
          end
        end

        # Used to convert attributes for a given type into a corresponding fieldset
        # (on form submit). 'type' is the checkbox value
        define_method :"#{type}=" do |attrs|
          @new_payments ||= {}
          record = OutgoingPaymentFieldsetForm.build(
            OutgoingsPayment.new(payment_type: type.to_s, **attrs),
            crime_application:
          )

          # Save on demand, not at end to allow partial updates of the form
          if types.include?(type.to_s)
            record.save
          else
            record.delete
          end

          # @new_payments used as a temporary store to allow error messages to
          # be displayed for invalid models
          @new_payments[type.value.to_s] = record
        end
      end

      def ordered_payment_types
        OutgoingsPaymentType::OTHER_PAYMENT_TYPES.map(&:to_s) & PAYMENT_TYPES_ORDER
      end

      def checked?(type)
        types.include?(type) || send(type.to_s)&.id.present?
      end

      private

      # Precedence: submitted values, stored values, empty OutgoingsPayment
      def find_or_create_outgoings_payment(type) # rubocop:disable Metrics/AbcSize
        if types.include?(type.to_s) && @new_payments&.key?(type.value.to_s)
          attrs = @new_payments[type.value.to_s].attributes
          return OutgoingsPayment.new(payment_type: type.to_s, **attrs)
        end

        outgoings_payment = crime_application.outgoings_payments.find_by(payment_type: type.value.to_s)
        return outgoings_payment if outgoings_payment

        OutgoingsPayment.new(payment_type: type.to_s)
      end

      # Individual outgoing_payment_fieldset_form are in charge of saving themselves
      def persist!
        true
      end
    end
  end
end
