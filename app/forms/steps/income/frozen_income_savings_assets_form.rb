module Steps
  module Income
    class FrozenIncomeSavingsAssetsForm < Steps::BaseFormObject
      include Steps::HasOneAssociation
      include TypeOfMeansAssessment
      include ApplicantOrPartner

      has_one_association :income

      attribute :has_frozen_income_or_assets, :value_object, source: YesNoAnswer

      validate :has_frozen_income_or_assets_selected

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

      def has_frozen_income_or_assets_selected
        return if YesNoAnswer.values.include?(has_frozen_income_or_assets) # rubocop:disable Performance/InefficientHashSearch

        errors.add(:has_frozen_income_or_assets, :blank, subject:)
      end
    end
  end
end
