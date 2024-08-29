module Steps
  module Partner
    class InvolvementForm < Steps::BaseFormObject
      include Steps::HasOneAssociation
      has_one_association :partner_detail

      attribute :involved_in_case, :value_object, source: YesNoAnswer
      validates :involved_in_case, inclusion: { in: :choices }

      def choices
        YesNoAnswer.values
      end

      private

      def persist!
        ::PartnerDetail.transaction do
          reset_address!

          partner_detail.update!(attributes)

          true
        end
      end

      def reset_address!
        return if involved_in_case.to_s == 'no'
        return if crime_application.partner&.home_address.nil?

        crime_application.partner.home_address.destroy!
      end
    end
  end
end
