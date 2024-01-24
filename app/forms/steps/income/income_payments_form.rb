module Steps
  module Income
    class IncomePaymentsForm < Steps::BaseFormObject
      # Ensure ordering of checkboxes (presentation) remains separate to the type definition
      # NOTE: remember to add any new types to this list otherwise it will not show on page edit
      PAYMENT_TYPES_ORDER = %w[
        maintenance
        private_pension
        state_pension
        interest_investment
        student_loan_grant
        board
        rent
        financial_support_with_access
        from_friends_relatives
        other
      ].freeze

      attribute :income_payments, array: true, default: [] # Used by BaseFormObject
      attribute :types, array: true, default: [] # Used by edit.html.erb to represent selected checkbox value
      attr_reader :new_payments

      validates_with IncomePaymentsValidator

      IncomePaymentType.values.each do |type| # rubocop:disable Style/HashEachMethods
        attribute type.to_s, :string

        # Used by govuk form component to retrieve values to populate the fields_for
        # for each type (on page load)
        define_method :"#{type}" do
          income_payment = crime_application.income_payments.find_by(payment_type: type.value.to_s)

          unless income_payment
            attrs = types.include?(type.to_s) ? @new_payments[type.value.to_s].attributes : {}
            puts "TYPE: #{type.to_s} - #{attrs}"
            income_payment = IncomePayment.new(payment_type: type.to_s, **attrs)
          end

          IncomePaymentFieldsetForm.build(income_payment, crime_application:).tap do |record|
            record.valid? if types.include?(type.to_s)
          end
        end

        # Used to convert attributes for a given type into a corresponding fieldset
        # (on form submit)
        define_method :"#{type}=" do |value|
          @new_payments ||= {}
          obj = IncomePaymentFieldsetForm.build(
            IncomePayment.new(payment_type: type.to_s, **value),
            crime_application:
          )
          puts "TYPES: #{types}"
          if types.include?(type.to_s) && obj.valid?
            obj.save
            puts "TYPE=: #{type.value}- valid? #{obj.valid?} - amount: #{obj.amount}"
          else
            obj.delete
          end

          @new_payments[type.value.to_s] = obj
        end
      end

      def income_payments
        @income_payments = crime_application.income_payments.map do |i|
          IncomePaymentFieldsetForm.build(i, crime_application:)
        end
      end

      def ordered_payment_types
        IncomePaymentType.values.map(&:to_s) & PAYMENT_TYPES_ORDER
      end

      def checked?(type)
        send(type.to_s)&.id.present? || types.include?(type)
      end

      private

      def valid_income_payments
        return [] unless @new_payments

        @new_payments.slice(*types).values.map(&:record).select(&:valid?)
      end

      def persist!
        # puts "DOING PERSISt!!!"
        # ::CrimeApplication.transaction do
        #   # Reset
        #   crime_application.income_payments.destroy_all

        #   # Rebuild
        #   crime_application.income_payments = valid_income_payments
        #   crime_application.save!
        # end
      end
    end
  end
end
