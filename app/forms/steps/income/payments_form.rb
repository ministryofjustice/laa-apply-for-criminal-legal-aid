module Steps
  module Income
    class PaymentsForm < Steps::BaseFormObject
      include Steps::HasOneAssociation
      has_one_association :income

      attribute :payments, array: true, default: []

      validate :validate_types

      def types=(ary)
        super(ary.compact_blank) if ary
      end

      private

      def validate_types
        errors.add(:types, :invalid) if (types - IncomePaymentType.values.map(&:to_s)).any?
      end

      def persist!
        income.update(
          attributes
        )
      end
    end
  end
end
