module Steps
  module Income
    class IncomePaymentsForm < Steps::BaseFormObject
      delegate :income_payment_details_attributes=, to: :crime_application

      attribute :income_payment, array: true, default: []
      attribute :maintenance, :string
      attribute :private_pension, :string
      attribute :state_pension, :string
      attribute :interest_investment, :string
      attribute :student_loan_grant, :string
      attribute :board, :string
      attribute :rent, :string
      attribute :financial_support_with_access, :string
      attribute :from_friends_relatives, :string
      attribute :other, :string

      private

      def persist!
        crime_application.save
      end
    end
  end
end
