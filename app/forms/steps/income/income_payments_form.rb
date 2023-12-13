module Steps
  module Income
    class IncomePaymentsForm < Steps::BaseFormObject
      include Steps::HasOneAssociation
      has_one_association :crime_application

      delegate :income_payment_details_attributes=, to: :crime_application
      attribute :income_payment_type, array: true, default: []

      def income_payment_details
        binding.pry
        @income_payment_details ||= crime_application.income_payments.map do |payment|
          IncomePaymentFieldsetForm.build(
            payment, crime_application:
          )
        end
      end

      private

      def persist!
        crime_application.save
      end
    end
  end
end
