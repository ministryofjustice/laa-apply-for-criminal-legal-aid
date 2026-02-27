module Steps
  module Capital
    class FrozenIncomeSavingsAssetsForm < Steps::Income::FrozenIncomeSavingsAssetsForm
      include Steps::HasOneAssociation

      has_one_association :capital

      private

      def persist!
        capital.update(
          attributes
        )
      end
    end
  end
end
