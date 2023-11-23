module Steps
  module Income
    class FrozenIncomeSavingsAssetsForm < Steps::BaseFormObject
      include Steps::HasOneAssociation
      has_one_association :income_details

      attribute :has_frozen_income_or_assets, :value_object, source: YesNoAnswer

      validates_inclusion_of :has_frozen_income_or_assets, in: :choices

      def choices
        YesNoAnswer.values
      end

      private

      def persist!
        income_details.update(
          attributes
        )
      end
    end
  end
end
