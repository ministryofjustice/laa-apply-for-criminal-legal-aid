module Steps
  module Outgoings
    class CouncilTaxForm < Steps::BaseFormObject
      include Steps::HasOneAssociation
      has_one_association :outgoings

      attribute :pays_council_tax, :value_object, source: YesNoAnswer
      attribute :amount, :pence

      validates :amount, presence: true, numericality: { greater_than: 0 }, if: -> { pays_council_tax? }
      validates_inclusion_of :pays_council_tax, in: :choices

      def self.build(crime_application)
        payment = crime_application.outgoings_payments.council_tax

        new.tap do |form|
          form.attributes = payment.slice(:amount) if payment
          form.pays_council_tax = crime_application.outgoings&.pays_council_tax
        end
      end

      def choices
        YesNoAnswer.values
      end

      private

      def persist!
        ::OutgoingsPayment.transaction do
          reset!
          outgoings.update(pays_council_tax:)

          if pays_council_tax?
            crime_application.outgoings_payments.create!(
              payment_type: OutgoingsPaymentType::COUNCIL_TAX.value,
              amount: amount,
              frequency: PaymentFrequencyType::ANNUALLY.value,
            )
          end
        end
      end

      def pays_council_tax?
        pays_council_tax&.yes?
      end

      def reset!
        crime_application.outgoings_payments.where(payment_type: OutgoingsPaymentType::COUNCIL_TAX.value).destroy_all
      end
    end
  end
end
