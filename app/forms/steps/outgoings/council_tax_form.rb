module Steps
  module Outgoings
    class CouncilTaxForm < Steps::BaseFormObject
      include Steps::HasOneAssociation
      has_one_association :outgoings

      attribute :pays_council_tax, :value_object, source: YesNoAnswer
      attribute :council_tax_amount, :integer

      validates_inclusion_of :pays_council_tax, in: :choices

      validates :council_tax_amount_in_pounds,
                presence: true,
                numericality: {
                  greater_than: 0,
                },
                if: -> { pays_council_tax? }

      def choices
        YesNoAnswer.values
      end

      def council_tax_amount_in_pounds=(amount_in_pounds)
        amount_in_pence = (amount_in_pounds.to_f * 100).round

        self.council_tax_amount = amount_in_pence
      end

      def council_tax_amount_in_pounds
        return unless council_tax_amount

        amount_in_pounds = council_tax_amount.dup / 100.0

        helpers.number_with_precision(amount_in_pounds, precision: 2)
      end

      private

      def persist!
        outgoings.update(
          attributes.merge(attributes_to_reset)
        )
      end

      def attributes_to_reset
        {
          'council_tax_amount' => (council_tax_amount if pays_council_tax?)
        }
      end

      def pays_council_tax?
        pays_council_tax&.yes?
      end

      def helpers
        ActionController::Base.helpers
      end
    end
  end
end
