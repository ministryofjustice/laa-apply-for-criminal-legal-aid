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
        ::Income.transaction do
          income.update(
            attributes
          )

          reset_dependants_if_needed

          true
        end
      end

      def reset_dependants_if_needed
        return if client_has_dependants.yes?

        crime_application.dependants = []
      end
    end
  end
end
