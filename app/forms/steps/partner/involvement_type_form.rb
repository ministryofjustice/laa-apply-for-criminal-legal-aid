module Steps
  module Partner
    class InvolvementTypeForm < Steps::BaseFormObject
      include Steps::HasOneAssociation
      has_one_association :partner_detail

      attribute :involvement_in_case, :value_object, source: PartnerInvolvementType
      validates :involvement_in_case, inclusion: { in: :choices }

      def choices
        PartnerInvolvementType.values
      end

      private

      def persist!
        ::PartnerDetail.transaction do
          partner_detail.update!(attributes)

          true
        end
      end
    end
  end
end
