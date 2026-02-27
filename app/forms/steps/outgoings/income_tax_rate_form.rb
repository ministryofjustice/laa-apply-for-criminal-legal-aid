module Steps
  module Outgoings
    class IncomeTaxRateForm < Steps::BaseFormObject
      include Steps::HasOneAssociation

      has_one_association :outgoings

      attribute :income_tax_rate_above_threshold, :value_object, source: YesNoAnswer

      validates_inclusion_of :income_tax_rate_above_threshold, in: :choices

      def choices
        YesNoAnswer.values
      end

      private

      def persist!
        outgoings.update(
          attributes
        )
      end
    end
  end
end
