module Steps
  module Capital
    class InvestmentsSummaryForm < Steps::BaseFormObject
      include TypeOfMeansAssessment
      include Steps::ApplicantOrPartner

      attr_reader :add_investment

      validates :add_investment, inclusion: { in: YesNoAnswer.values }

      delegate :investments, to: :crime_application

      def choices
        YesNoAnswer.values
      end

      def add_investment=(attribute)
        return unless attribute

        @add_investment = YesNoAnswer.new(attribute)
      end

      private

      # NOTE: this step is not persisting anything to DB.
      # We only use `add_investment` transiently in the decision tree.
      def persist!
        true
      end
    end
  end
end
