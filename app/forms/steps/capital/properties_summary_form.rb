module Steps
  module Capital
    class PropertiesSummaryForm < Steps::BaseFormObject
      include TypeOfMeansAssessment
      include Steps::ApplicantOrPartner

      attr_reader :add_property

      validates_inclusion_of :add_property, in: :choices

      delegate :properties, to: :crime_application

      def choices
        YesNoAnswer.values
      end

      def add_property=(attribute)
        return unless attribute

        @add_property = YesNoAnswer.new(attribute)
      end

      private

      # NOTE: this step is not persisting anything to DB.
      # We only use `add_property=` transiently in the decision tree.
      def persist!
        true
      end
    end
  end
end
