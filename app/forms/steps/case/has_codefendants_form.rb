module Steps
  module Case
    class HasCodefendantsForm < Steps::BaseFormObject
      include Steps::HasOneAssociation
      has_one_association :case

      attribute :has_codefendants, :yes_no

      validates_inclusion_of :has_codefendants, in: :choices

      def choices
        YesNoAnswer.values
      end

      private

      def persist!
        kase.update(
          attributes
        )
      end
    end
  end
end
