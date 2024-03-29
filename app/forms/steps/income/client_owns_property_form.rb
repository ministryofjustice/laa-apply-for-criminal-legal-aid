module Steps
  module Income
    class ClientOwnsPropertyForm < Steps::BaseFormObject
      include Steps::HasOneAssociation
      has_one_association :income

      attribute :client_owns_property, :value_object, source: YesNoAnswer

      validates_inclusion_of :client_owns_property, in: :choices

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
