module Steps
  module Partner
    class InvolvementForm < Steps::BaseFormObject
      include Steps::HasOneAssociation
      has_one_association :partner_detail

      attribute :involvement_in_case, :value_object, source: PartnerInvolvementType
      validates :involvement_in_case, inclusion: { in: :choices }

      def choices
        PartnerInvolvementType.values
      end

      private

      def persist!
        partner_detail.update(attributes)
      end
    end
  end
end
