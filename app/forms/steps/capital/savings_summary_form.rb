module Steps
  module Capital
    class SavingsSummaryForm < Steps::BaseFormObject
      include TypeOfMeansAssessment
      include Steps::ApplicantOrPartner

      attr_reader :add_saving

      validates_inclusion_of :add_saving, in: :choices

      delegate :savings, to: :crime_application

      def choices
        YesNoAnswer.values
      end

      def add_saving=(attribute)
        return unless attribute

        @add_saving = YesNoAnswer.new(attribute)
      end

      private

      # NOTE: this step is not persisting anything to DB.
      # We only use `add_saving` transiently in the decision tree.
      def persist!
        true
      end
    end
  end
end
