module Steps
  module Client
    class IsMeansTestedForm < Steps::BaseFormObject
      attribute :is_means_tested, :value_object, source: YesNoAnswer

      validates_inclusion_of :is_means_tested, in: :choices
      validate :cifc_application

      # CRIMAPP-1249 temporary fix to default application to being means tested
      def is_means_tested
        super || YesNoAnswer::YES
      end

      def choices
        YesNoAnswer.values
      end

      private

      def persist!
        crime_application.update(
          attributes
        )
      end

      def cifc_application
        if crime_application.cifc? && is_means_tested.to_s == 'no'
          errors.add(:is_means_tested, "Change in Financial Circumstances application must be means tested")
        end
      end
    end
  end
end
