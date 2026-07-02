module Steps
  module Income
    class FrozenIncomeOrAssetsSubjectForm < Steps::BaseFormObject
      include Steps::HasOneAssociation

      has_one_association :income

      attribute :frozen_income_or_assets_subject, :value_object, source: FrozenIncomeOrAssetsSubjectType

      validates :frozen_income_or_assets_subject,
                inclusion: { in: FrozenIncomeOrAssetsSubjectType.values }

      def choices
        FrozenIncomeOrAssetsSubjectType.values
      end

      private

      def persist!
        income.update(
          attributes
        )
      end
    end
  end
end
