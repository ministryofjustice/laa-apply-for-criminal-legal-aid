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
          attributes.merge(attributes_to_reset)
        )
      end

      def attributes_to_reset
        return {} unless client_owns_property?

        {
          'has_savings' => nil,
        }
      end

      def client_owns_property?
        client_owns_property&.yes?
      end
    end
  end
end
