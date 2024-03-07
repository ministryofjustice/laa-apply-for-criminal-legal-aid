module Steps
  module Outgoings
    class HousingPaymentTypeForm < Steps::BaseFormObject
      include Steps::HasOneAssociation
      has_one_association :outgoings

      attribute :housing_payment_type, :value_object, source: HousingPaymentType

      validates :housing_payment_type,
                inclusion: { in: :choices }

      def choices
        HousingPaymentType.values
      end

      private

      def persist!
        outgoings.update(
          attributes
        )
        @housing_payment = existing_housing_payment || crime_application.outgoings_payments.create(
          payment_type: housing_payment_type
        )
      end

      # :nocov:
      def existing_housing_payment
        crime_application.outgoings_payments.where(payment_type: housing_payment_type).first
      end
      # :nocov:
    end
  end
end
