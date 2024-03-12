module Steps
  module Capital
    class OtherInvestmentTypeForm < InvestmentTypeForm
      private

      def persist!
        @investment = crime_application.investments.create!(investment_type:)
      end
    end
  end
end
