module Steps
  module Case
    class HasCodefendantsForm < Steps::BaseFormObject
      include Steps::HasOneAssociation

      has_one_association :case

      attribute :has_codefendants, :value_object, source: YesNoAnswer

      validates_inclusion_of :has_codefendants, in: :choices

      def choices
        YesNoAnswer.values
      end

      private

      def persist!
        kase.update(
          attributes.merge(
            reset_codefendants_if_needed
          )
        )
      end

      def reset_codefendants_if_needed
        has_codefendants.no? ? { codefendants: [] } : {}
      end
    end
  end
end
