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

      def case
        income.crime_application.case
      end

      private

      def persist!
        ::Income.transaction do
          income.update(
            attributes
          )

          reset_dependants_if_needed
        end

        income
      end

      def reset_dependants_if_needed
        return if client_has_dependants.yes?

        crime_application.case.dependants = []
      end
    end
  end
end
