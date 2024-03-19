module Steps
  module Capital
    class InvestmentTypeForm < Steps::BaseFormObject
      attr_accessor :investment_type

      validates :investment_type, presence: true

      attr_reader :investment

      def choices
        InvestmentType.values
      end

      private

      def persist!
        return true if investment_type == 'none'

        @investment = incomplete_investment_for_type || crime_application.investments.create!(investment_type:)
      end

      def incomplete_investment_for_type
        return nil unless investment_type

        crime_application.investments.where(investment_type:).reject(&:complete?).first
      end
    end
  end
end
