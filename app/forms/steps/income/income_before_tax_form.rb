module Steps
  module Income
    class IncomeBeforeTaxForm < Steps::BaseFormObject
      include Steps::HasOneAssociation
      has_one_association :income_details, through: :applicant

      # threshold being £12,475 currently
      attribute :income_above_threshold, :value_object, source: YesNoAnswer

      validates_inclusion_of :income_above_threshold, in: :choices

      def choices
        YesNoAnswer.values
      end

      private

      def persist!
        income_details.update(
          attributes
        )
      end
    end
  end
end
