module Steps
  module Capital
    class FrozenIncomeOrAssetsSubjectForm < Steps::Income::FrozenIncomeOrAssetsSubjectForm
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
