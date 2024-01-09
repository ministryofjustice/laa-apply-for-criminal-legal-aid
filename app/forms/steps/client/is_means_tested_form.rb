module Steps
  module Client
    class IsMeansTestedForm < Steps::BaseFormObject
      attribute :is_means_tested, :value_object, source: YesNoAnswer

      validates_inclusion_of :is_means_tested, in: :choices

      def choices
        YesNoAnswer.values
      end

      private

      def persist!
        crime_application.update(
          attributes
        )
      end
    end
  end
end
