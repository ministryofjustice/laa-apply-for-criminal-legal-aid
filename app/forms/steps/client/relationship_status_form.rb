module Steps
  module Client
    class RelationshipStatusForm < Steps::BaseFormObject
      include Steps::HasOneAssociation

      has_one_association :partner_detail

      attribute :relationship_status, :value_object, source: ClientRelationshipStatusType
      attribute :separation_date, :multiparam_date

      validates_inclusion_of :relationship_status, in: :choices
      validates :separation_date, presence: true, multiparam_date: true, if: -> { separated? }

      def choices
        ClientRelationshipStatusType.values
      end

      def separated?
        relationship_status == ClientRelationshipStatusType::SEPARATED
      end

      private

      def persist!
        partner_detail.update(
          attributes.merge(attributes_to_reset)
        )
      end

      def attributes_to_reset
        return {} if separated?

        {
          'separation_date' => nil,
        }
      end
    end
  end
end
