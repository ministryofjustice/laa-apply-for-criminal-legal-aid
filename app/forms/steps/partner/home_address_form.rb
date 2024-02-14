module Steps
  module Partner
    class HomeAddressForm < Steps::BaseFormObject
      include Steps::HasOneAssociation
      has_one_association :partner_details, through: :partner

      attribute :same_home_address_as_client, :value_object, source: YesNoAnswer
      validates :same_home_address_as_client, inclusion: { in: YesNoAnswer.values }

      def choices
        YesNoAnswer.values
      end

      private

      def persist!
        partner_details.update(same_home_address_as_client:)
      end
    end
  end
end

