module Steps
  module Partner
    class RelationshipForm < Steps::BaseFormObject
      include Steps::HasOneAssociation

      has_one_association :partner_detail

      attribute :relationship_to_partner, :value_object, source: RelationshipToPartnerType
      validates :relationship_to_partner, inclusion: { in: :choices }

      def choices
        RelationshipToPartnerType.values
      end

      private

      def persist!
        partner_detail.update(attributes)
      end
    end
  end
end
