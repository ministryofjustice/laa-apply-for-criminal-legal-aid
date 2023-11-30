module Steps
  module Income
    class ClientHasDependantsForm < Steps::BaseFormObject
      include Steps::HasOneAssociation
      has_one_association :income

      attribute :client_has_dependants, :value_object, source: YesNoAnswer

      validates_inclusion_of :client_has_dependants, in: :choices

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
