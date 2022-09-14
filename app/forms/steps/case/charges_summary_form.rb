module Steps
  module Case
    class ChargesSummaryForm < Steps::BaseFormObject
      include Steps::HasOneAssociation
      has_one_association :case

      attribute :add_offence, :value_object, source: YesNoAnswer
      validates :add_offence, inclusion: { in: :choices }

      delegate :charges, to: :kase

      def choices
        YesNoAnswer.values
      end

      private

      # NOTE: this step is not persisting anything to DB.
      # We only use `add_offence` transiently in the decision tree.
      def persist!
        true
      end
    end
  end
end
