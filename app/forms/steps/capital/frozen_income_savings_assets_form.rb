module Steps
  module Capital
    class FrozenIncomeSavingsAssetsForm < Steps::Income::FrozenIncomeSavingsAssetsForm
      include Steps::HasOneAssociation

      has_one_association :capital

      private

      def persist!
        capital.update(
          attributes.merge(attributes_to_reset)
        )
      end

      def attributes_to_reset
        return {} unless has_frozen_income_or_assets.no?

        { 'frozen_income_or_assets_subject' => nil }
      end
    end
  end
end
