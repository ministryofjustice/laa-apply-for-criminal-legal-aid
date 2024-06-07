module Steps
  module Outgoings
    class HousingPaymentTypeForm < Steps::BaseFormObject
      include Steps::HasOneAssociation
      include TypeOfMeansAssessment
      include ApplicantOrPartner

      has_one_association :outgoings

      attribute :housing_payment_type, :value_object, source: HousingPaymentType

      validates :housing_payment_type,
                inclusion: { in: :choices }

      def choices
        HousingPaymentType.values
      end

      private

      def persist!
        ::OutgoingsPayment.transaction do
          reset_outgoings_payments!
          reset_council_tax!

          outgoings.update!(attributes)
        end
      end

      def reset_outgoings_payments!
        return if crime_application.outgoings&.housing_payment_type.to_s == housing_payment_type.to_s

        crime_application.outgoings_payments.housing_payments.destroy_all
      end

      def reset_council_tax!
        return unless housing_payment_type == HousingPaymentType::BOARD_AND_LODGING

        outgoings.update!(pays_council_tax: nil)
        crime_application.outgoings_payments.where(payment_type: OutgoingsPaymentType::COUNCIL_TAX.value).destroy_all
      end
    end
  end
end
