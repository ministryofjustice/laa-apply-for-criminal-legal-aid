module Steps
  module Income
    class BusinessesSummaryForm < Steps::BaseFormObject
      attr_reader :add_business

      validates :add_business, inclusion: { in: YesNoAnswer.values }

      alias subject record

      delegate :businesses, to: :record

      def choices
        YesNoAnswer.values
      end

      def add_business=(attribute)
        return unless attribute

        @add_business = YesNoAnswer.new(attribute)
      end

      private

      # NOTE: this step is not persisting anything to DB.
      # We only use `add_business` transiently in the decision tree.
      def persist!
        true
      end
    end
  end
end
