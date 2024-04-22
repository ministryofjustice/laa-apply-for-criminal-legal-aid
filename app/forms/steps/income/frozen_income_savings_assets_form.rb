module Steps
  module Income
    class FrozenIncomeSavingsAssetsForm < Steps::BaseFormObject
      include Steps::HasOneAssociation
      has_one_association :income

      attribute :has_frozen_income_or_assets, :value_object, source: YesNoAnswer

      validates_inclusion_of :has_frozen_income_or_assets, in: :choices

      def choices
        YesNoAnswer.values
      end

      private

      def persist!
        income.update(
          attributes.merge(attributes_to_reset)
        )
      end

      def attributes_to_reset
        return {} unless frozen_income_or_assets?

        {
          'client_owns_property' => nil,
          'has_savings' => nil,
        }
      end

      def frozen_income_or_assets?
        has_frozen_income_or_assets&.yes?
      end
    end
  end
end
