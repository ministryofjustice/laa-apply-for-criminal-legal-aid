module Steps
  module Capital
    class OtherInvestmentTypeForm < Steps::BaseFormObject
      attr_accessor :investment_type

      validates :investment_type, presence: true
      validates :investment_type, inclusion: { in: InvestmentType.values.map(&:to_s) }

      attr_reader :investment

      def choices
        InvestmentType.values
      end

      private

      def persist!
        @investment = crime_application.investments.create!(investment_type:)
      end
    end
  end
end
