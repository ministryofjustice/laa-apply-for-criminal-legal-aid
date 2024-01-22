module Steps
  module Income
    class IncomePaymentsForm < Steps::BaseFormObject
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
      attribute :types, array: true, default: [] # Used by edit.html to represent selected checkbox value

      attr_reader :new_payments

      IncomePaymentType.values.each do |type| # rubocop:disable Style/HashEachMethods
        attribute type.to_s, :string

        define_method :"#{type}" do
          income_payment = crime_application.income_payments.find_by(payment_type: type.value.to_s) || IncomePayment.new(payment_type: type.to_s)

          obj = IncomePaymentFieldsetForm.build(
            income_payment,
            crime_application:
          )

          if (types.include?(type.to_s)) && !obj.valid?
          #   obj.errors.each do |error|
          #     puts "THE ERROR #{error.type}"
          #     self.errors.add(
          #       error.attribute,
          #       error.type,
          #       message: I18n.t(
          #         "#{obj.model_name.i18n_key}.summary.#{error.attribute}.#{error.type}",
          #         scope: [:activemodel, :errors, :models]
          #       )
          #     )
          #   end
            puts "OBJ VALID [#{type}][#{types}]: #{obj.valid?} - #{obj.errors.inspect}"
          end

          obj
        end

        define_method :"#{type}=" do |value|
          @new_payments ||= {}
          obj = IncomePaymentFieldsetForm.build(
            IncomePayment.new(payment_type: type.to_s, **value),
            crime_application:
          )
          @new_payments[type.value.to_s] = obj
        end
      end

      validates_with IncomePaymentsValidator

      # Use FieldserForm as a typed formobject for each IncomePayment
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

      def persist!
        ::CrimeApplication.transaction do
          # Reset
          crime_application.income_payments.destroy_all

          # Rebuild
          crime_application.income_payments = @new_payments.slice(*types).values.map(&:record)
          crime_application.save!
        end
      end
    end
  end
end
