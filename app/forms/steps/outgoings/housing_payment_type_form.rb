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
      end
    end
  end
end
