module Steps
  module Income
    class IncomeBeforeTaxForm < Steps::BaseFormObject
      include Steps::HasOneAssociation
      has_one_association :income

      # threshold being £12,475 as of Nov 2023
      attribute :income_above_threshold, :value_object, source: YesNoAnswer

      validates_inclusion_of :income_above_threshold, in: :choices

      def choices
        YesNoAnswer.values
      end

      private

      def persist!
        income.update(
          attributes.merge(attributes_to_reset)
        )
      end

      def attributes_to_reset
        return {} unless income_above_threshold?

        {
          'client_owns_property' => nil,
          'has_frozen_income_or_assets' => nil,
          'has_savings' => nil,
        }
      end

      def income_above_threshold?
        income_above_threshold&.yes?
      end
    end
  end
end
