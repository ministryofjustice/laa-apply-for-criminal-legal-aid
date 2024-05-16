module Steps
  module Client
    class RelationshipStatusForm < Steps::BaseFormObject
      attribute :client_relationship_status, :value_object, source: ClientRelationshipStatusType
      attribute :client_relationship_separated_date, :multiparam_date

      validates_inclusion_of :client_relationship_status, in: :choices
      validates :client_relationship_separated_date, presence: true, multiparam_date: true, if: -> { separated? }

      def choices
        ClientRelationshipStatusType.values
      end

      def separated?
        client_relationship_status == ClientRelationshipStatusType::SEPARATED
      end

      private

      def persist!
        crime_application.update(
          attributes.merge(attributes_to_reset)
        )
      end

      def attributes_to_reset
        return {} if separated?

        {
          'client_relationship_separated_date' => nil,
        }
      end
    end
  end
end
