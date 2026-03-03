module Steps
  module Partner
    class SameAddressForm < Steps::BaseFormObject
      include Steps::HasOneAssociation

      has_one_association :partner_detail

      attribute :has_same_address_as_client, :value_object, source: YesNoAnswer
      validates :has_same_address_as_client, inclusion: { in: :choices }

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
        return if has_same_address_as_client.to_s == 'no'
        return if crime_application.partner&.home_address.nil?

        crime_application.partner.home_address.destroy!
      end
    end
  end
end
