require 'laa_crime_schemas'

module Steps
  module Income
    class IncomePaymentsForm < Steps::BaseFormObject
      PAYMENT_TYPES_ORDER = LaaCrimeSchemas::Types::IncomePaymentType.values

      attribute :income_payments, array: true, default: [] # Used by BaseFormObject
      attribute :types, array: true, default: [] # Used by edit.html.erb to represent selected checkbox value
      attr_reader :new_payments

      validates_with IncomePaymentsValidator

      IncomePaymentType.values.each do |type| # rubocop:disable Style/HashEachMethods
        attribute type.to_s, :string

        # Used by govuk form component to retrieve values to populate the fields_for
        # for each type (on page load). Trigger validation on load.
        define_method :"#{type}" do
          IncomePaymentFieldsetForm.build(find_or_create_income_payment(type), crime_application:).tap do |record|
            record.valid? if types.include?(type.to_s)
          end
        end

        # Used to convert attributes for a given type into a corresponding fieldset
        # (on form submit). 'type' is the checkbox value
        define_method :"#{type}=" do |attrs|
          @new_payments ||= {}
          record = IncomePaymentFieldsetForm.build(
            IncomePayment.new(payment_type: type.to_s, **attrs),
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
        IncomePaymentType.values.map(&:to_s) & PAYMENT_TYPES_ORDER
      end

      def checked?(type)
        types.include?(type) || send(type.to_s)&.id.present?
      end

      private

      # Precedence: submitted values, stored values, empty IncomePayment
      def find_or_create_income_payment(type) # rubocop:disable Metrics/AbcSize
        if types.include?(type.to_s) && @new_payments&.key?(type.value.to_s)
          attrs = @new_payments[type.value.to_s].attributes
          return IncomePayment.new(payment_type: type.to_s, **attrs)
        end

        income_payment = crime_application.income_payments.find_by(payment_type: type.value.to_s)
        return income_payment if income_payment

        IncomePayment.new(payment_type: type.to_s)
      end

      # Individual income_payments_fieldset_forms are in charge of saving themselves
      def persist!
        true
      end
    end
  end
end
