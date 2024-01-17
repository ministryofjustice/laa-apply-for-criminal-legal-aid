module Steps
  module Income
    class IncomePaymentsForm < Steps::BaseFormObject
      delegate :income_payments_attributes=, to: :crime_application

      #attribute :income_payment, array: true, default: [] # Useless
      attribute :income_payments, array: true, default: [] # Useless
      attribute :types, array: true, default: [] # Useless
      #attribute :payment_types, array: true, default: []

      IncomePaymentType.values.each do |type|
        attribute type.to_s, :string
      end


      attribute :new_payments, array: true, default: []


      #validates_with IncomePaymentsValidator

      # Generates fieldset forms for all payment_types and then populate with persisted values
      def income_payments
        @income_payments = (crime_application.income_payments.reload + other_payment_types).map do |i|
          IncomePaymentFieldsetForm.build(i, crime_application:)
        end
      end

      def all_payment_types
        @all_payment_types ||= IncomePaymentType.values
      end

      def other_payment_types
        @other_payment_types ||= all_payment_types
                                   .reject { |i| crime_application.income_payments.map(&:payment_type).include?(i.to_s) }
                                   .map { |ipt| IncomePayment.new(payment_type: ipt.to_s) }
      end


      def new_fieldset(payment_type:)
        IncomePaymentFieldsetForm.build(IncomePayment.new(payment_type:), crime_application:)
      end

      def maintenance
        crime_application.income_payments.find_by(payment_type: 'maintenance')# || new_fieldset(payment_type: 'maintenance')
      end

      def maintenance=(val)
        new_payments << IncomePaymentFieldsetForm.build(IncomePayment.new(payment_type: 'maintenance', **val), crime_application:)
      end

      def private_pension
        crime_application.income_payments.find_by(payment_type: 'private_pension') || new_fieldset(payment_type: 'private_pension')
      end

      def state_pension
        crime_application.income_payments.find_by(payment_type: 'state_pension') || new_fieldset(payment_type: 'state_pension')
      end

      def interest_investment
        crime_application.income_payments.find_by(payment_type: 'interest_investment') || new_fieldset(payment_type: 'interest_investment')
      end

      def student_loan_grant
        crime_application.income_payments.find_by(payment_type: 'student_loan_grant') || new_fieldset(payment_type: 'student_loan_grant')
      end

      def board
        crime_application.income_payments.find_by(payment_type: 'board') || new_fieldset(payment_type: 'board')
      end

      def rent
        crime_application.income_payments.find_by(payment_type: 'rent') || new_fieldset(payment_type: 'rent')
      end

      def financial_support_with_access
        crime_application.income_payments.find_by(payment_type: 'financial_support_with_access') || new_fieldset(payment_type: 'financial_support_with_access')
      end

      def from_friends_relatives
        crime_application.income_payments.find_by(payment_type: 'from_friends_relatives')# || new_fieldset(payment_type: 'from_friends_relatives')
      end

      def from_friends_relatives=(val)
        new_payments << IncomePaymentFieldsetForm.build(IncomePayment.new(payment_type: 'from_friends_relatives', **val), crime_application:)
      end

      def other
        crime_application.income_payments.find_by(payment_type: 'other') #|| new_fieldset(payment_type: 'other')
      end

      def other=(val)
        new_payments << IncomePaymentFieldsetForm.build(IncomePayment.new(payment_type: 'other', **val), crime_application:)
      end


      def none
        nil
      end

      private

      # Strips out un-selected payment types prior to saving
      def persist!
        ::CrimeApplication.transaction do



          crime_application.income_payments = new_payments.map(&:record)
          crime_application.save!
        end
      end
    end
  end
end
