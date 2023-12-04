module Steps
  module Income
    class HasSavingsForm < Steps::BaseFormObject
      include Steps::HasOneAssociation
      has_one_association :income

      attribute :has_savings, :value_object, source: YesNoAnswer

      validates_inclusion_of :has_savings, in: :choices

      def choices
        YesNoAnswer.values
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
