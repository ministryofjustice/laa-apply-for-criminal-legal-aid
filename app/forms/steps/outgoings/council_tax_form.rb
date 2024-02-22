module Steps
  module Outgoings
    class CouncilTaxForm < Steps::BaseFormObject
      include Steps::HasOneAssociation
      has_one_association :outgoings

      attribute :pays_council_tax, :value_object, source: YesNoAnswer
      attribute :council_tax_amount, :pence

      validates_inclusion_of :pays_council_tax, in: :choices

      validates :council_tax_amount,
                presence: true,
                numericality: {
                  greater_than: 0,
                },
                if: -> { pays_council_tax? }

      def choices
        YesNoAnswer.values
      end

      private

      def persist!
        if pays_council_tax?
          council_tax_payment_entry.first_or_initialize.tap do |payment_type|
            payment_type.update!(
              amount: council_tax_amount,
              payment_type: OutgoingsPaymentType::COUNCIL_TAX.to_s,
              frequency: PaymentFrequencyType::ANNUALLY.to_s
            )
          end
        else
          council_tax_payment_entry.destroy
        end
      end

      def pays_council_tax?
        pays_council_tax&.yes?
      end

      def council_tax_payment_entry
        crime_application.outgoings_payments.where(payment_type: OutgoingsPaymentType::COUNCIL_TAX.to_s)
      end
    end
  end
end
