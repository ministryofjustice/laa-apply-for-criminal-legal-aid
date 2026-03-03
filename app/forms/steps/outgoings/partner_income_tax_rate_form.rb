module Steps
  module Outgoings
    class PartnerIncomeTaxRateForm < Steps::BaseFormObject
      include Steps::HasOneAssociation

      has_one_association :outgoings

      attribute :partner_income_tax_rate_above_threshold, :value_object, source: YesNoAnswer

      validates_inclusion_of :partner_income_tax_rate_above_threshold, in: :choices

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
