module Steps
  module Outgoings
    class CouncilTaxForm < Steps::BaseFormObject
      include Steps::HasOneAssociation
      include TypeOfMeansAssessment
      include ApplicantAndPartner

      has_one_association :outgoings

      attribute :pays_council_tax, :value_object, source: YesNoAnswer
      attribute :amount, :pence

      validates :amount, presence: true, numericality: { greater_than: 0 }, if: -> { pays_council_tax? }
      validates_inclusion_of :pays_council_tax, in: :choices

      validate :council_tax_payable?, if: -> { pays_council_tax? }

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
              payment_type: OutgoingsPaymentType::COUNCIL_TAX,
              amount: amount,
              frequency: PaymentFrequencyType::ANNUALLY,
            )
          end

          true
        end
      end

      def pays_council_tax?
        pays_council_tax&.yes?
      end

      def reset!
        crime_application.outgoings_payments.where(payment_type: OutgoingsPaymentType::COUNCIL_TAX.value).destroy_all
      end

      def council_tax_payable?
        return true if crime_application.outgoings&.housing_payment_type != OutgoingsPaymentType::BOARD_AND_LODGING.to_s

        errors.add(:pays_council_tax, :not_payable)
      end
    end
  end
end
